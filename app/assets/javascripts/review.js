$(document).ready(function() {
 $('.profile-content').on('click', '.review', function(event) {
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
  })
})