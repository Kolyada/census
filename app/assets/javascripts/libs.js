String.prototype.toProperCase = function () {
    return this.replace(/\w\S*/g, function(txt){return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();});
};

var titleString = function(obj){
    return obj['ZipCode']+', '+obj['City'].toProperCase()+', '+
        obj['County'].toProperCase()+', '+obj['StateFullName']+'('+obj['StateAbbreviation']+')'
}

var clsBtn = '<a href="#" class="close">&times;</a>'
var enterKeyCode = 13
var compareGroupMaxLength = 5
var message = function(text, type, timeout){
    type = type || 'error'
    timeout = timeout || 3000
    switch  (type){
        case 'error':
            typeId = 'error'
            break;
        case 'notice':
            typeId = 'notice'
            break;
        default:
            typeId = 'default'
    }
    var $box = $('#'+typeId+'MessageBox')
    $box.html(text)
    $box.show()
    setTimeout(function(){$box.hide()},timeout)
}
var findSelected = function(ZipCode){
    return document.AutocompleteLastResult.filter(function(x){return parseInt(x.ZipCode)==ZipCode})[0]
}

var zipcodeOverviewFill = function(options){
    var $overviewBlock = $('#overviewBlock')
    options = options || {}
    $('#overviewZipCode').data('ZipCode',options['ZipCode'])
    $('#overviewZipCode').html('ZipCode ('+options['ZipCode']+')' || null)
    $('#overviewState').html(options['StateFullName']+'('+options['StateAbbreviation']+')' || null)
    $('#overviewCounty').html(options['County'] || null)
    $('#overviewCity').html(options['City'] || null)
    $('#overviewAliases').html(options['CityAliases'] || null)
    options['ZipCode'] ? $overviewBlock.show('slow') : $overviewBlock.hide()
}

var alwaysInGroup = function(ZipCode){
    return $('#compareGroup [data-zip='+ZipCode+']').length!=0
}
var compareGroupSize = function(){
    return $('#compareGroup .alert-box').length
}
var clearCompareGroup = function(){
    $("#compareGroup .alert-box").remove()
    $("#compareGroup").hide()
}

var addToCompareGroup = function(obj){
    var ZipCode = obj['ZipCode']
    var $compareGroup = $('#compareGroup')
    var $newElem = $('<div class="alert-box" data-alert data-lat='+obj['Latitude']+' data-lng='+
        obj['Longitude']+' data-zip='+obj['ZipCode']+' data-title="'+titleString(obj)+'">'+titleString(obj)+
        clsBtn+'</div>')
    if (alwaysInGroup(ZipCode)){
        message('ZipCode always in compare group','notice',5000)
        return
    }
    if (compareGroupSize()>=compareGroupMaxLength){
        message('Compare group is full','notice',5000)
        return
    }
    $compareGroup.prepend($newElem)
    $("#compareGroup").show()
}

var showCompareGroupAtGmaps = function(){
    var objects = $('#compareGroup .alert-box')
    if (objects.length==0){
        message('Compare group is empty')
        return
    }
    markers.map(function(m){
        m.setMap(null)
    })
    markers.length = 0
    markersContent.length = 0
    var bounds = new google.maps.LatLngBounds();
    for (var i=0;i<objects.length;i++){
        var obj = $(objects[i])
        var lat = parseFloat(obj.data('lat'))
        var lng = parseFloat(obj.data('lng'))
        var title = String(obj.data('zip'))
        var LatLng = new google.maps.LatLng(lat,lng);
        var marker = new google.maps.Marker({position: LatLng,title:title,map:map});
        markers.push(marker)
        markersContent.push(obj.data('title'))
        var infoWindow = new google.maps.InfoWindow()
        google.maps.event.addListener(marker, 'click', function(){
            var titleContent = markersContent[i]
            infoWindow.setContent(titleContent)
            infoWindow.open(map, this);
        });
        bounds.extend(marker.position);
    }
    map.fitBounds(bounds);
}
