$(document).ready(function() {
 $('#history_tab').on('click', function(event) {
    event.preventDefault();
    event.stopPropagation();
    var $details = $(event.target);
    $.ajax({
      url: $details[0].href,
      type: 'GET',
      }).done(function (response) {
          $('.profile-content').children().hide();
          $('.profile-content').append(response);
      }).fail(function (response) {
        alert("Can Not Render Your Parcels Due to Error")
      })

   $('#parcels_tab').on('click', function(event) {
      $('.profile-content').children().show();
      $('#history_show').hide();
    });

   $('#trips_tab').on('click', function(event) {
       $('.profile-content').children().show();
      $('#history_show').hide();
    });
 });
})
