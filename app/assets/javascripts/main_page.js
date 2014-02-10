var markers = []
var markersContent = []
var map
function initialize() {
    var bounds = new google.maps.LatLngBounds();
    map = new google.maps.Map(document.getElementById('map'));
}

google.maps.event.addDomListener(window, 'load', initialize);

$(document).ready(function(){
    $('#GoogleMapsDetails').on('opened',function(){
        google.maps.event.trigger(map, 'resize')
        showCompareGroupAtGmaps()
    })
    $('#topbarSearch').keypress(function(e){if (e.which==enterKeyCode)$('#topbarSearchButton').click()})
    $('#topbarSearchButton').click(function(){
        var $search = $('#topbarSearch').val()
        if ($search.length>0){$.get("/search?data=" + $search,null,onLoadData,'json')}
    })
    $('#clearCompareGroup').click(clearCompareGroup)

    $('#addToCompareGroup').click(function(){
        var ZipCode = $('#overviewZipCode').data('ZipCode')
        if (!ZipCode){
            message('error during process, reload page')
            return
        }
        var obj = findSelected(ZipCode)
        addToCompareGroup(obj)
    })
    $( "#tags" ).autocomplete({
        delay: 500,
        minLength: 3,
        source: function(request,response){
            var $search = request.term
            console.log('request')
            $.get("/search?type=shortdata&data=" + $search,null,function(result){
                var status = result['status']
                if (status=='error'){
                    message(result['errors'],status)
                    return
                }
                var notice = result['notice']
                if (notice){message(result['notice'],'notice',6000)}
                var data = result['data']
                if (data.length>0){
                    document.AutocompleteLastResult = data
                    var showList = data.map(function(obj){
                        var showString=titleString(obj)
                        return showString
                    })
                    response(showList)
                }
            },'json')
        },
        select: function(event,ui){
            var ZipCode = parseInt(ui.item.label)
            var obj = findSelected(ZipCode)
            var StateFullName = obj.StateFullName
            var StateAbbreviation = obj.StateAbbreviation
            var County = obj.County
            var CityAliases = obj.CityAbbreviation.join(',')
            var City = obj.City
            zipcodeOverviewFill({
                'ZipCode':ZipCode,
                'StateFullName':StateFullName,
                'StateAbbreviation':StateAbbreviation,
                'County':County,
                'CityAliases':CityAliases,
                'City':City
            })
        }
    });
})