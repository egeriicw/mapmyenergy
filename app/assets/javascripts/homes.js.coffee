# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

root = this
module = window.PG ||= {}
$ = jQuery

root.MME = do ( module, $ ) ->
  self = module.utils = module.utils || {}

  self.init = =>
    console.log 'init'

    centerLatLng = new google.maps.LatLng 42.374158009074925, -71.11333154960937

    mapOptions =
      center: centerLatLng
      zoom: 12
      mapTypeId: google.maps.MapTypeId.ROADMAP # ROADMAP, SATELLITE, HYBRID, TERRAIN
      mapTypeControl: true
      overviewMapControl: true
      scaleControl: true
      zoomControl: true

    @map = new google.maps.Map $("#map-canvas").get(0), mapOptions

    @geocoder = new google.maps.Geocoder()

    @infowindow = null

    # google.maps.event.addListener @map, 'idle', addRandomHouses

    addRealHouses @properties

    google.maps.event.addListener @map, 'click', =>
      @infowindow.close() if @infowindow

    $(document).on 'submit', '#frmAddress', ( e ) ->
      e.preventDefault()
      console.log 'submit'
      codeAddress()

    codeAddress()

    $(document).on 'click', '[data-address]', ->
      $('#modal-performance h3').text $(@).data('address')

  self.openInfoWindow = ( house ) ->
    @infowindow = new google.maps.InfoWindow content: house.markerContent
    @infowindow.open @map, house.g.marker

  # Private

  addHouseMarker = ( house ) ->
    console.log 'addHouseMarker', house

    house.g = {}

    house.g.latLng = new google.maps.LatLng house.lat, house.lng

    house.g.marker = new google.maps.Marker
      icon: getIconFromRating house.rating
      position: house.g.latLng
      title: "ER #{ house.rating }"

    house.g.marker.setMap @map

    house.markerContent = """
      <div class="marker-content">
        <img src='/assets/house-preview.png'/>
        <h2>#{ house.address }</h2>
        <h2>#{ Math.floor(Math.random()*5) + 2 } Beds, #{ Math.floor(Math.random()*4) + 1 } Bath</h2>
        <h2>ZEstimate $#{ numberWithDelimiter house.zest }</h2>
        <h2>Est. HERS Effect <font color='#{ getColorFromRating house.rating }'>#{ getEffectFromRating house.rating, house.zest }</font></h2>
        <h2>HERS Energy Rating <font color='#{ getColorFromRating house.rating }'>#{ house.rating }</font></h2>
        <a href="#modal-performance" data-toggle='modal' data-address='#{ house.address }'>Performance</a>
      </div>
    """

    google.maps.event.addListener house.g.marker, 'click', =>
      @infowindow.close() if @infowindow
      @infowindow = new google.maps.InfoWindow
        content: house.markerContent
      @infowindow.open @map, house.g.marker

  addRandomHouses = ( num = 3 ) =>
    llBounds = @map.getBounds()

    console.log 'llBounds', llBounds

    ne = llBounds.getNorthEast()
    sw = llBounds.getSouthWest()

    num.times ->
      rnd1 = Math.random()
      rnd2 = Math.random()

      rndLat = ne.lat() - ((ne.lat() - sw.lat()) * rnd1)
      rndLng = ne.lng() + ((sw.lng() - ne.lng()) * rnd2)

      randMarker = [rndLat, rndLng]

      console.log 'random', randMarker

      addHouseMarker
        lat: rndLat
        lng: rndLng
        rating: Math.floor(Math.random() * 200)

  addRealHouses = ( houses ) ->
    $.map houses, ( house, i ) ->
      addHouseMarker house

  codeAddress = ->
    address = $.trim $('#q').val()

    if !!address
      @geocoder.geocode address: address, ( results, status ) ->
        if status == google.maps.GeocoderStatus.OK
          @map.setCenter results[0].geometry.location
          # addRandomHouses()
        else
          alert "Address not found: #{ status }"

  getIconFromRating = ( rating ) ->
    icon = switch
      when rating <= 65 then '/assets/home-green.png'
      when rating <= 100 then '/assets/home-yellow.png'
      else '/assets/home-red.png'

  getColorFromRating = ( rating ) ->
    color = switch
      when rating <= 65 then 'green'
      when rating <= 100 then '#B3B300' #yellow
      else 'red'

  getEffectFromRating = ( rating, zest ) ->
    change = numberWithDelimiter(Math.floor(zest * Math.abs(rating - 100) * 0.0009 ))
    effect = switch
      when rating <= 100 then "+$#{change}"
      else "-$#{change}"

  numberWithDelimiter = ( num = '' ) ->
    num.toString().replace /\B(?=(\d{3})+(?!\d))/g, ','

  module

Number::times = (fn) ->
  do fn for [1..@valueOf()]
  return