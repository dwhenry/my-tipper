class LeaguesController < ApplicationController
  before_action :authenticate_user!

  def index
    @leagues = League.joins(%{
        LEFT JOIN players
          ON players.league_id = leagues.id
      })
      .select(:id, :name, :password, :public, :code, 'count(players.id) as player_count', :event)
      .group(:id, :name, :password, :public, :code)
      .where(['public is true or exists(select from players p where p.league_id = leagues.id and p.user_id = ?)', current_user.id])
      .order('event DESC, count(players.id) DESC, name')
      .having('count(players.id) > 0')
      .limit(10)
    @members = Player.where(user_id: current_user.id).group(:league_id).maximum(:request_state)
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
      redirect_to leagues_path(paramify(highlight: @league.id))
    else
      render :new
    end
  end

  def join
    @league = League.find(params[:id]) || League.find_by(code: params[:id])
    if @league.password.blank? || @league.password == params[:password]
      request_state = @league.confirmation_required ? 'requested' : 'accepted'
      @league.players.create(user_id: current_user.id, request_state: request_state, access: 'player')

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
    @current_player = Player.find_by(league_id: @league.id, user_id: current_user.id)
    @points = Fixture.where(event: event, picks: { user: @league.users })
                .includes(:picks)
                .group(:user_id)
                .order('sum(picks.score)')
                .sum('picks.score')
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
