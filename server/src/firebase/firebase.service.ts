import { Injectable } from '@nestjs/common';
import { getAuth, UserRecord } from 'firebase-admin/auth';

import { getFirestore } from 'firebase-admin/firestore';
@Injectable()
export class FirebaseService {
  async getAuthUserWithEmail(email: string): Promise<UserRecord> {
    const user = await getAuth().getUserByEmail(email);
    return user;
  }
  async getAllUsers(): Promise<FirebaseFirestore.DocumentData> {
    const snapshot = await getFirestore().collection('Users').get();
    return snapshot.docs.map((doc) => {
      let d = { ...doc.data(), id: doc.id };

      return d;
    });
  }

  async getFirebaseUserData(
    uid: string,
  ): Promise<FirebaseFirestore.DocumentData> {
    const snapshot = await getFirestore()
      .collection('Users')
      .doc(uid)
      .get()
      .then((res) => res.data());
    return snapshot;
  }

  async getFirestoreData(uid: string, collectionName: string) {
    const snapshot = await getFirestore()
      .collection(collectionName)
      .doc(uid)
      .get()
      .then((res) => res.data());
    return snapshot;
  }

  async getFirestoreDocumentWhere(
    collectionName: string,
    fieldToFind: string,
    valueToFind: string,
  ) {
    const snapshot = await getFirestore()
      .collection(collectionName)
      .where(fieldToFind, '==', valueToFind)
      .get()
      .then((res) => res.docs[0]);
    return snapshot == undefined
      ? undefined
      : { id: snapshot.id, data: snapshot.data() };
  }
  //!Replace object
  // eslint-disable-next-line @typescript-eslint/ban-types
  async updateAuthUser(uid: string, data: object): Promise<void> {
    await getAuth().updateUser(uid, data);
  }

  //!Replace object
  // eslint-disable-next-line @typescript-eslint/ban-types
  async updateFirestoreUser(uid: string, data: object): Promise<void> {
    await getFirestore().collection('Users').doc(uid).update(data);
  }
  async updateFirestoreData(collectionName: string, uid: string, data: object) {
    await getFirestore()
      .collection(collectionName)
      .doc(uid)
      .set(data, { merge: true });
  }
  async verifyIdToken(id: string): Promise<string> {
    return getAuth()
      .verifyIdToken(id)
      .then((decodedToken) => {
        const uid = decodedToken.uid;
        return uid;
      })
      .catch((error) => {
        return '';
      });
  }
}
