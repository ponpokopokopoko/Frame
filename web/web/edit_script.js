function setImageURL(imageUrl) {
  const imageElement = document.getElementById('myImage');
  if (imageElement) {
    imageElement.src = imageUrl;
  } else {
    console.error('Image element not found');
  }
}