$(function() {
  window.addEventListener('message', function(event) {
    if (event.data.type === "openGeneral"){
              $('#waiting').show();
              $('body').addClass("active");
    } else if(event.data.type === "balanceHUD") {
        $('.curbalance').html(event.data.balance);
    } else if (event.data.type === "closeAll"){
              $('#waiting, #waiting1, #deleting, #loginin, #createaccount, #general, #settings, #transferUI, #withdrawUI, #depositUI, #topbar').hide();
              $('body').removeClass("active");
    } else if (event.data.type === "succlogin"){
      $('#loginin').hide();
      $('.username1').html(event.data.player);
      $('.creditnum').html(event.data.creditcard);
      $('.pinnum').html(event.data.pin);
      $('.accnumber').html(event.data.accNum);
      $('#general').show();
    } else if(event.data.type === "saymyname") {
      $('.username2').html(event.data.player);
    } else if(event.data.type === "deletedatall") {
      $('#general, #settings, #waiting, #deleting, #waiting1, #loginin, #createaccount, #transferUI, #withdrawUI, #depositUI, #topbar').hide();
      $('body').removeClass("active");
      $.post('http://gb_banking/NUIFocusOff', JSON.stringify({}));
    } else if(event.data.type === "withdone") {
      $('#withdrawUI').hide();
      $('#general').show();
    } else if(event.data.type === "depodone") {
      $('#depositUI').hide();
      $('#general').show();
    }	else if(event.data.type === "transdone") {
      $('#transferUI').hide();
      $('#general').show();
    }	
    else if(event.data.type === "failed") {
      $('#deleting').hide();
      $('#settings').show();
    }
    else if (event.data.type === "result") {
      if (event.data.t == "success")
        $("#result").attr('class', 'alert-green');
      else
        $("#result").attr('class', 'alert-orange');
      $("#result").html(event.data.m).show().delay(5000).fadeOut();
    }
  });
});
  $('.btn-sign-out').click(function(){
        $('#general, #settings, #waiting, #deleting, #waiting1, #loginin, #createaccount, #transferUI, #withdrawUI, #depositUI, #topbar').hide();
        $('body').removeClass("active");
        $.post('http://gb_banking/NUIFocusOff', JSON.stringify({}));
    })
    $('.back').click(function(){
        $('#depositUI, #withdrawUI, #transferUI, #settings, #deleting').hide();
        $('#general').show();
    })
$('.back1').click(function(){
        $('#loginin, #createaccount').hide();
        $('#waiting').show();
    })
    $('#deposit').click(function(){
        $('#general').hide();
        $('#depositUI').show();
    })
    $('#withdraw').click(function(){
        $('#general').hide();
        $('#withdrawUI').show();
    })
    $('#transfer').click(function(){
        $('#general').hide();
        $('#transferUI').show();
    })
$('#settbutt').click(function(){
        $('#general').hide();
        $('#settings').show();
    })
$("#logon").click(function(){
  $('#waiting').hide();
  $('#loginin').show();
})

$("#passchange").click(function(){
  $('#settings').hide();
  $('#deleting').show();
})

$("#newpin").click(function(){
  $('#settings').hide();
  $.post('https://gb_banking/pinnew', JSON.stringify({}))
  $('#general').show();
})
$("#newcard").click(function(){
  $('#settings').hide();
  $.post('https://gb_banking/cardnew', JSON.stringify({}))
  $('#general').show();
})
$("#newmain").click(function(){
  $('#settings').hide();
  $.post('https://gb_banking/changeMain', JSON.stringify({}))
  $('#general').show();
})
$("#createac").click(function(){
  $('#waiting').hide();
  $.post('https://gb_banking/getname', JSON.stringify({}))
  $('#createaccount').show();
})
$("#login1").submit(function(e){
  e.preventDefault();
  $.post('https://gb_banking/login', JSON.stringify({
    login: $("#login").val(),
    password: $("#password").val()
  }))
})
$("#create1").submit(function(e){
  e.preventDefault();
  $.post('https://gb_banking/createaccountnew', JSON.stringify({
    login12: $("#login12").val(),
    password1: $("#password1").val(),
    removecode: $("#removecode").val()
  }))
  $('#createaccount').hide();
  $('#waiting').show();
})
    $("#deposit1").submit(function(e) {
      e.preventDefault();
      $.post('https://gb_banking/deposit', JSON.stringify({
          amount: $("#amount").val()
      }));
  $('#depositUI').hide();
  $('#general').show();
  $("#amount").val('');
});
$("#transfer1").submit(function(e) {
      e.preventDefault();
      $.post('https://gb_banking/transfer', JSON.stringify({
    to: $("#to").val(),
          amountt: $("#amountt").val()
      }));
  $("#amountt").val('');
});
$("#withdraw1").submit(function(e) {
  e.preventDefault();
      $.post('https://gb_banking/withdrawl', JSON.stringify({
          amountw: $("#amountw").val()
      }));
  $("#amountw").val('');
});
$("#deletit").submit(function(e) {
  e.preventDefault();
  $.post('https://gb_banking/usunkonto', JSON.stringify({
    deletecode: $("#deletecode").val(),
    backupcode: $("#backupcode").val()
  }))
});
document.onkeyup = function(data){
      if (data.which == 27){
          $('#general, #settings, #waiting, #waiting1, #deleting, #loginin, #createaccount, #transferUI, #withdrawUI, #depositUI, #topbar').hide();
          $('body').removeClass("active");
          $.post('https://gb_banking/NUIFocusOff', JSON.stringify({}));
      }
}