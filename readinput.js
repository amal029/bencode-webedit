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
	    // console.log(output);
	    console.log(reader.result.length);
	    console.log(output.length);
	    $.ajax({
		type:"POST",
		url:"/ajax/hdata",
		data: {'fcontent':output},
		success:function(response){
		    $("#sformat").html(response);
		}
	    });
	}

	reader.readAsBinaryString(file);	
    });
}
