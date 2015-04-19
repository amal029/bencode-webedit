// The function that finds if it is a torrent file
function isATorrentFile(file) {
    var ret = false;
    if(file.name.match(/.torrent/i)) ret = true;
    return ret;
}

window.onload = function() {
    var fileInput = document.getElementById('myInput');

    fileInput.addEventListener('change', function(e) {
	var file = fileInput.files[0];
	console.log(file);
	var reader = new FileReader();
	reader.onload = function(e) {
	    var output = "";
	    for(i=0;i<reader.result.length;++i){
		var temp = reader.result.charCodeAt(i).toString(16)
		if(temp.length < 2)
		    output += "0"+temp;
		else
		    output += temp;
	    }
	    var res = ""; 	// The json response from server
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
    console.log($(this));
    event.preventDefault();
    // Get some values from elements on the page:
    var $form = $( "#torrentForm" );
    var tfn = $form.find( "input[id='torrent-file-name']" ).val(),
	url = $form.attr( "action" );
    console.log(tfn);
    console.log(url);
}
