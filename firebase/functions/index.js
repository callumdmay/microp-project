const functions = require('firebase-functions');
const audio = require('./audio_conversion');
const speech = require('./speech_recognition');

exports.generateMonoAudio = functions.storage.object().onChange(event => audio.generateMonoAudio(event));
exports.recognizeSpeech = functions.https.onRequest((req, res) => speech.recognizeSpeech(req, res));
