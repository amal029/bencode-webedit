// The function that finds if it is a torrent file
function isATorrentFile(file) {
    var ret = false;
    if(file.name.match(/.torrent/i)) ret = true;
    return ret;
}

// Generate client side html for torrent file
function torrentFileHtml (file, response){
}

// Generate client side html for non-torret file.
function bencodeHtml(file, response){
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
