// Imports the Google Cloud client library
const speech = require('@google-cloud/speech');

exports.recognizeSpeech = (req, res) => {

  // Creates a client
  const client = new speech.SpeechClient();

  // Configuration values for speech detection
  const gcsUri = 'gs://microp-70683.appspot.com/audio_output.flac';
  const encoding = 'FLAC';
  const languageCode = 'en-US';
  const config = {
    encoding: encoding,
    languageCode: languageCode,
  };
  const audio = {
    uri: gcsUri,
  };

  const request = {
    config: config,
    audio: audio,
  };

  // Detects speech in the audio file
  client
  .recognize(request)
  .then(data => {
    const response = data[0];
    const transcription = response.results
      .map(result => result.alternatives[0].transcript)
      .join('\n');
    console.log(`Transcription: `, transcription);
    //Return the result of the speech in an http response with status code 200
    res.status(200).json({ result: transcription });
  })
  .catch(err => {
    console.error('ERROR:', err);
    res.status(500).json({ error: `There was a server error:\n${err}` });
  });
};
