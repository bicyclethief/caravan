$(document).ready(function() {
  $('#creation-form').on('keydown', 'input', function(event) {
    if(event.keyCode == 13) {
    	event.preventDefault();
      var $target = $(event.target);
    	if ($target.attr('id') == 'origin_address_address_string'){
    		$("#button-1").click();
    	} else if($target.attr('id') == 'destination_address_address_string'){
    		$("#button-2").click();
    	} else if ($target.attr('id') == "text-field-3") {
    		$("#button-3").click()
    	}
    }
  });
});