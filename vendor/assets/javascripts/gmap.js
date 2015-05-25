GmapAutoComplete = function(address) {
  function getFieldIds() {
    addressIds = {
      field: address + "_address_string",
      latitude: address + "_latitude",
      longitude: address + "_longitude",
      zipCode: address + "_zip_code",
      city: address + "_city",
      state: address + "_state",
      streetAddress: address + "_street_address"
    }
    return addressIds
  }
  // Autocomplete
  var addressInput = document.getElementById(getFieldIds().field);
  var addressField = new google.maps.places.Autocomplete(addressInput);
  var place;
  var photos;
  // Autocomplete Listener
  google.maps.event.addListener(addressField, 'place_changed', function() {
    place = addressField.getPlace();

    document.getElementById(getFieldIds().latitude).value = place.geometry.location.lat();
    document.getElementById(getFieldIds().longitude).value = place.geometry.location.lng();

    var address = '';
    if (place.address_components) {
      address = [(place.address_components[0] &&
                  place.address_components[0].short_name || ''),
                 (place.address_components[1] &&
                  place.address_components[1].short_name || ''),
                 (place.address_components[2] &&
                  place.address_components[2].short_name || '')
                ].join(' ');
    }
    // Autofill the fields in the form. TODO: improve parsing of the returned JSON data.
    var address = place.address_components;
    if (address[address.length - 1]) {
      var zipcode = address[address.length - 1].long_name;
    };
    if (address[address.length - 2]) {
      var country = address[address.length - 2].long_name;
    };
    if (address[address.length - 3]) {
       var state = address[address.length - 3].short_name
     };
    if (address.length === 9 ) {
      var city = address[address.length - 3].long_name;
     };
    if (address.length === 8 ) {
      var city = address[address.length - 5].long_name;
     };
    if (address[0]) {
      var streetnumber = address[0].long_name;
    };
    if (address[1]) {
      var streetname = address[1].long_name;
    };
    if (place.name) {
      var location_name = place.name;
    }

    if (zipcode){
      document.getElementById(getFieldIds().zipCode).value = zipcode;
    }
    if (city) {
      document.getElementById(getFieldIds().city).value = city;
    }
    if (state) {
      document.getElementById(getFieldIds().state).value = state;
    }
    if (location_name) {
      document.getElementById(getFieldIds().streetAddress).value = location_name;
    }
  });
}