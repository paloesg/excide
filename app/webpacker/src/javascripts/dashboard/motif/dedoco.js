// Onclick to pass file data into Dedoco's visual build via iframe
window.handleDedocoClick = () => {
  try {
    const iframe = document.getElementById("esign-iframe");
    const file = document.getElementById("esign-file").files[0];
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onloadend = () => {
      iframe?.contentWindow?.postMessage({
        subject: 'file',
        data: reader.result,
        name: file.name
      }, '*')
    }
  } catch(error){
    console.log("Error is: ", error);
  }
}