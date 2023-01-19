window.displayFileField = (input) => {
  const fileField = input.closest(".wrapper").firstElementChild;
  const label = input.closest(".wrapper").nextElementSibling.nextElementSibling;
  const infoArea = label.querySelector(".file-upload-filename");
  infoArea.innerHTML = input.files[0].name;
  infoArea.classList.remove("hidden");
}