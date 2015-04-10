window.onload = function() {
    var fileInput = document.getElementById('myInput');

    fileInput.addEventListener('change', function(e) {
	var file = fileInput.files[0];
	console.log(file);
	var reader = new FileReader();
	reader.onload = function(e) {
	    var output = "";
	    for(i=0;i<reader.result.length;++i){
		output += reader.result.charCodeAt(i).toString(16);
	    }
	    // console.log(output);
	    $.ajax({
		type:"POST",
		url:"/ajax/hdata",
		// data: {'fcontent':reader.result},
		data: {'fcontent':output},
		success:function(response){
		    $("#sformat").html(response);
		}
	    });
	}

	reader.readAsBinaryString(file);	
    });
}
