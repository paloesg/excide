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
  // const iframe = document.getElementById("esign-iframe");
  // console.log("iframe, ", iframe);
  // const taskId = $('#task').data('taskId');
  // console.log("What is task id: ", taskId);
  // $.ajax({
  //   type: "GET",
  //   url: "/motif/task/" + taskId + "/document_data"
  //   // dataType: "file",
  // }).done(function(data){
  //   console.log("What is datatype: ", data)
  // }).fail(function (data) {
  //   console.log("What is erro: ", data)
  // });
  // if (iframe){
  //   const queryString = window.location.search;
  //   const urlParams = new URLSearchParams(queryString);
  //   const blobData = $('#blob-info').data('blob');
  //   const blob = new Blob([JSON.stringify(blobData)], {
  //     type: "application/pdf",
  //   });
  //   console.log("What is blob data: ", blob);
  //   const reader = new FileReader();
  //   reader.readAsDataURL(blob);
  //   reader.onloadend = () => {
  //     iframe?.contentWindow?.postMessage({
  //       subject: 'file',
  //       data: reader.result,
  //       name: blobData.name
  //     }, '*')
  //   }
  //   console.log("Clicked into dedoco end");
  // } else {
  //   console.log("Outside of dedoco")
  // }
  // try {
  //   const iframe = document.getElementById("esign-iframe");
  //   const file = document.getElementById("esign-file").files[0];
    // const reader = new FileReader();
    // reader.readAsDataURL(file);
    // reader.onloadend = () => {
    //   iframe?.contentWindow?.postMessage({
    //     subject: 'file',
    //     data: reader.result,
    //     name: file.name
    //   }, '*')
    // }
  // } catch(error){
  //   console.log("Error is: ", error);
  // }
// })