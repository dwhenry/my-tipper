class LeaguesController < ApplicationController
  before_action :authenticate_user!

  def index
    @leagues = League.joins(%{
        LEFT JOIN (
          SELECT
            league_id,
            sum(case request_state when 'accepted' then 1 else 0 end) as player_count,
            sum(case request_state when 'requested' then 1 else 0 end) as requested_count,
            sum(case request_state when 'baned' then 1 else 0 end) as baned_count
          FROM players
          GROUP BY league_id
        ) as p ON p.league_id = leagues.id
      })
      .select('*', :player_count, :requested_count, :baned_count)
      .where(['public is true or exists(
         select from players p where p.league_id = leagues.id and p.user_id = ? and p.request_state in (\'requested\',\'accepted\'))', current_user.id])
      .order('event DESC, player_count DESC, name')
      .limit(10)

    @members = Player.where(user_id: current_user.id).group(:league_id).maximum(:request_state)
    @access = Player.where(user_id: current_user.id).group(:league_id).maximum(:access)
  end

  # def show
  #   @league = League.find_by(code: params[:id])
  #   if @league.password.blank? || @league.password == params[:password]
  #     @league.players.create(user_id: current_user.id)
  #     redirect_to leagues_path(paramify)
  #   else
  #     render :password
  #   end
  # end

  def new
    @league = League.new(public: true)
  end

  def create
    @league = League.new(league_params)
    if @league.create(current_user)
      redirect_to leagues_path(paramify(highlight: @league.id, league: nil))
    else
      render :new
    end
  end

  def join
    @league = League.find_by(id: params[:id]) || League.find_by(code: params[:id])
    if @league.password.blank? || @league.password == params[:password]
      request_state = @league.confirmation_required ? 'requested' : 'accepted'
      player = @league.players.find_by(user_id: current_user.id)
      if player
        player.update(request_state: 'requested') if player.request_status == 'removed'
      else
        @league.players.create(user_id: current_user.id, request_state: request_state, access: 'player')
      end

      redirect_to leagues_path(paramify)
    else
      flash[:error] = 'Invalid password' if params[:password]
      render :password
    end
  end

  def destroy
    Player.where(
      league_id: params[:id],
      user_id: current_user.id
    ).delete_all
    redirect_to leagues_path(paramify)
  end

  def view
    @league = League.includes(players: :user).find(params[:id])
    @current_player = @league.players.where(request_state: 'accepted').find_by!(user_id: current_user.id)
    @points = Fixture.where(event: event, picks: { user: @league.users })
                .includes(:picks)
                .group(:user_id)
                .order('sum(picks.score)')
                .sum('picks.score')
  end

  def action
    current_player = Player.find_by!(league_id: params[:id], user_id: current_user.id)
    player = Player.find_by!(league_id: params[:id], user_id: params[:player_id])

    raise('Not an admin') unless current_player.access != 'player'

    case params['action']
    when 'make_admin'
      return if player.access != 'player'
      player.update!(access: 'admin')
    when 'remove_admin'
      return if player.access == 'primary'
      player.update!(access: 'player')
    when 'approve'
      player.request_state == 'approved'
    when 'remove'
      return if player.access == 'primary'
      player.request_state == 'removed'
    when 'bane'
      return if player.access == 'primary'
      player.request_state == 'baned'
    else
      raise "Unknown action: #{params[:action]}"
    end
  end

  private

  def league_params
    params.require(:league).permit(
      :name,
      :public,
      :password,
      :prize,
      :requirements,
      :confirmation_required
    )
  end
end
