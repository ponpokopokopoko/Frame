const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

exports.createNewUser = functions.auth.user().onCreate(async (user) => {
  try {
    // 新規ユーザーに付与するカスタムクレーム
    const customClaims = {
      isNewUser: true,
    };

    // ユーザーにカスタムクレームを設定
    await admin.auth().setCustomUserClaims(user.uid, customClaims);

    // Firestoreのフラグ用ドキュメントを更新
    await admin.firestore().collection("user_status").doc(user.uid).set({
      customClaimsSet: true,
    });

    console.log("Custom claims set for user:", user.uid);
  } catch (error) {
    console.error("Error setting custom claims:", error);
  }
});

exports.updateTagCounts = functions.firestore
    .document("posts/{postId}")
    .onWrite(async (change, context) => {
      const beforeTags = change.before.data()?.tags || [];
      const afterTags = change.after.data()?.tags || [];


      console.log("beforeTags:", beforeTags);
      console.log("afterTags:", afterTags);
      console.log("typeof beforeTags:", typeof beforeTags);
      console.log("typeof afterTags:", typeof afterTags);
      console.log(
          "bool", JSON.stringify(beforeTags) !== JSON.stringify(afterTags),
      );

      /* const keys1 = new Set(Object.keys(beforeTags));
      const keys2 = new Set(Object.keys(afterTags));*/
      // タグの変更があった場合のみ処理
      if (JSON.stringify(beforeTags) !== JSON.stringify(afterTags)) {
        const db = admin.firestore();
        const tagCountsRef = db.collection("tagCounts");

        console.log("a");


        /* // afterTagsがオブジェクトの場合
        const addedTags = new Set(Object.keys(afterTags).filter((tag) => {
          Object.keys(beforeTags).length === 0 ||
           !Object.keys(beforeTags).includes(tag);
        }));*/
        // const beforeTagsSet = new Set(Object.keys(beforeTags));
        const addedTags = afterTags.filter((tag) => {
          return !beforeTags.includes(tag);
        });

        console.log("Object.keys(afterTags):", Object.keys(afterTags));
        console.log("Object.keys(beforeTags):", Object.keys(beforeTags));
        /* console.log(
            "Object.keys(beforeTags).length === 0 :",
            Object.keys(beforeTags).length === 0,
        );*/
        console.log("addedTags:", addedTags);
        console.log("typeof addedTags:", typeof addedTags);

        /* const addedTags = Object.keys(afterTags);
        console.log("addedTags:", addedTags);*/

        addedTags.forEach(async (tag) => {
          console.log("i");
          const doc = await tagCountsRef.doc(tag).get();
          await tagCountsRef.doc(tag).set({
            tagName: tag,
            count: (doc.exists ? doc.data().count : 0) + 1,
          } /* {merge: true}*/);
        });


        console.log("b");

        /* // 削除されたタグの出現回数を減らす
        const removedTags = new Set(
            Array.from(beforeTags.keys()).filter((tag) => {
              !afterTags.includes(tag);
            }));*/

        // afterTagsがオブジェクトの場合
        const removedTags = beforeTags.filter((tag) => {
          return !(afterTags.includes(tag));
        });
        removedTags.forEach(async (tag) => {
          const doc = await tagCountsRef.doc(tag).get();
          if (doc.exists && doc.data().count > 1) {
            await tagCountsRef.doc(tag).update({
              count: admin.firestore.FieldValue.increment(-1),
            });
            console.log("c");
          } else {
            await tagCountsRef.doc(tag).delete();
          }
        });
      }
    });
