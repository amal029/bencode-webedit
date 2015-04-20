// The function that finds if it is a torrent file
function isATorrentFile(file) {
    var ret = false;
    if(file.name.match(/.torrent/i)) ret = true;
    return ret;
}

var output = "";

window.onload = function() {
    var fileInput = document.getElementById('myInput');

    fileInput.addEventListener('change', function(e) {
	var file = fileInput.files[0];
	console.log(file);
	var reader = new FileReader();
	reader.onload = function(e) {
	    for(i=0;i<reader.result.length;++i){
		var temp = reader.result.charCodeAt(i).toString(16)
		if(temp.length < 2)
		    output += "0"+temp;
		else
		    output += temp;
	    }
	    // Ask for the HTML form template
	    $.ajax({
		type:"POST",
		url:"/ajax/myhtml",
		data: {'fname':file.name,
		       'fcontent':output,
		       'torrentfile':isATorrentFile(file)},
		success:function(response){
		    $("#file").html(response);
		}
	    });
	}

	reader.readAsBinaryString(file);	
    });
}

// The htorrent update submitter
function torrentSubmit(event){
    event.preventDefault();
    // Get some values from elements on the page:
    var $form = $( "#torrentForm" );
    var tfn = $form.find( "input[id='torrent-file-name']" ).val(),
	turls = $form.find("input[id^='url']"),
	tcon = $form.find("input[id='torrent-created-on']").val(),
	tcby = $form.find("input[id='torrent-created-by']").val(),
	tcom = $form.find("input[id='torrent-comment']").val(),
	murl = $form.attr( "action" );
    var tvals = jQuery.map(turls, function (v) {return v.value;});
    console.log(tvals);
    $.ajax({
	type:"POST",
	url:murl,
	traditional:true,
	data: {'fname':tfn,
	       'fcontent':output,
	       'tcby':tcby,
	       'tcon':tcon,
	       'tcom':tcom,
	       'turls':tvals},
	success:function(response){
	    $("#file").html(response);
	}
    });
}
