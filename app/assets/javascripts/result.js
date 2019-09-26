$(function () {
  $.each($('#result .pick'), function() {
    var _this = $(this);
    var callback;

    function setPick() {
      var amount = _this.find('.amount').val();
      var message;
      if (amount === 0) {
        message = 'Draw';
      } else if(amount < 0) {
        message = _this.find('.home').val() + ' by ' + Math.abs(amount);
      } else {
        message = _this.find('.away').val() + ' by ' + amount;
      }
      if(amount !== 0 && callback) {
        message = message + ' (saving...)';
      }
      // _this.find('#result').val(amount);
      _this.find('.pick-output').html(message)
    };
    setPick();


    _this.find(".slider").slider({
      value: _this.find('.amount').val(),
      min: -100,
      max: 100,
      step: 1,
      slide: function (event, ui) {
        _this.find(".pick-output").removeClass('next-game-in')
        _this.find("#result").val(ui.value);
        setPick();
      }
    });
  })

});
