from __future__ import annotations

from functools import lru_cache
from typing import Annotated

from fastapi import Depends
from google.cloud import firestore

@lru_cache(maxsize=1)
def _init_client() -> firestore.Client:
    return firestore.Client()

def get_firestore_client() -> firestore.Client:
    return _init_client()

FirestoreDep = Annotated[firestore.Client, Depends(get_firestore_client)]
