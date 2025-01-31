//document.addEventListener('DOMContentLoaded', () => {

  // JavaScriptコード
function uploadFile(filePath) {
    document.addEventListener('DOMContentLoaded', () => {
    import { getStorage, ref, uploadBytesResumable } from "firebase/storage";

    // Firebase Storageの初期化
    const storage = getStorage();

    // アップロードするファイル
    const file = document.getElementById('fileInput').files[0];

    // Storage上のパス
    const storageRef = ref(storage, 'images/newimage.jpg');

    // アップロード開始
    uploadBytesResumable(storageRef, file)
      .then((snapshot) => {
        // アップロード完了時の処理
        console.log('Uploaded a blob or file!');
      })
      .catch((error) => {
        // エラー発生時の処理
        switch (error.code) {
          case 'storage/unauthorized':
            // ユーザーに認証を求める
            break;
          case 'storage/unknown':
            // Unknown error occurred, inspect error.serverResponse
            break;
        }
      });
  /*const fileInput = document.getElementById('fileInput');

    if (!fileInput) {
      console.error('fileInput要素が見つかりません');
      // Flutter にエラーを通知
      window.flutter_inappwebview.postMessage(JSON.stringify({ event: 'uploadError', error: 'fileInput要素が見つかりません' }));
      return;
    }

  const file = fileInput.files[0];

  if (!file) {
    console.error('ファイルが選択されていません');
    // Dart側にエラーを通知する
    window.flutter_inappwebview.postMessage(JSON.stringify({ event: 'uploadError', error: 'ファイルが選択されていません' }));
    return;
  }

  const formData = new FormData();
  formData.append('file', file);

  fetch('https://your-server/upload', {
    method: 'POST',
    body: formData
  })
  .then(response => {
    if (!response.ok) {
      throw new Error('ネットワークエラーが発生しました');
    }
    return response.json();
  })
  .then(data => {
    console.log('Upload successful:', data);
    window.flutter_inappwebview.postMessage(JSON.stringify({ event: 'uploadSuccess', data: data }));
  })
  .catch(error => {
    console.error('Error:', error);
    window.flutter_inappwebview.postMessage(JSON.stringify({ event: 'uploadError', error: error.message }));
  });*/
  });
}

