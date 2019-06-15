$(function () {
  $.each($('#picks .pick'), function() {
    var _this = $(this);
    var callback;

    function setPick() {
      var amount = _this.find('.amount').val();
      var message;
      if (amount === 0) {
        message = 'Please select a winning margin';
      } else if(amount < 0) {
        message = _this.find('.home').val() + ' by ' + Math.abs(amount);
      } else {
        message = _this.find('.away').val() + ' by ' + amount;
      }
      if(amount !== 0 && callback) {
        message = message + ' (saving...)';
      }
      _this.find('.pick').html(message)
    };
    setPick();

    function save() {
      var fixture_id = _this.data('fixture_id');
      var picks = {}
      picks["fix_" + fixture_id] = _this.find(".amount").val()
      $.ajax({
        url: "/picks",
        type: "POST",
        data: {
          picks: picks
        },
        success: function(resp) {
          setPick();
        },
        error: function(resp) {
          callback = setTimeout(function() {
            callback = null;
            save();
          }, 500);
          setPick();
        }
      });
      setPick()
    }

    _this.find(".slider").slider({
      value: _this.find('.amount').val(),
      min: -100,
      max: 100,
      step: 1,
      slide: function (event, ui) {
        if(callback) {
          clearTimeout(callback);
          callback = null;
        }
        if(ui.value !== 0) {
          _this.find(".pick").removeClass('next-game-in')
        }
        _this.find(".amount").val(ui.value);
        _this.find(".pick").html();
        callback = setTimeout(function() {
          callback = null;
          save();
        }, 2000);
        setPick();
      }
    });
  })

});
