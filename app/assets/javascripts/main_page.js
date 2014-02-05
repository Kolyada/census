var enterKeyCode = 13
var message = function(text, type='error',timeout = 3000){
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

var onLoadData=function(result){
    var status = result['status']
    if (status=='error'){message(result['errors'],status)}
    var notice = result['notice']
    if (notice){message(result['notice'],'notice',6000)}
    var data = result['data']
    alert(data)
}

$(document).ready(function(){
    $('#topbarSearch').keypress(function(e){if (e.which==enterKeyCode)$('#topbarSearchButton').click()})
    $('#topbarSearchButton').click(function(){
        var $search = $('#topbarSearch').val()
        if ($search.length>0){$.get("/search?data=" + $search,null,onLoadData,'json')}
    })
})