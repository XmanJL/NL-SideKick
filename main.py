from dotenv import load_dotenv
import os
from openai import OpenAI, api_key
import json
import pyttsx3
from nltk.tokenize import TweetTokenizer
import wordfreq
import ssl
import time
from flask import Flask
from flask import send_file
import re
from threading import Lock
from wordfreq import word_frequency
from pydub import AudioSegment
from gtts import gTTS
app = Flask(__name__)


@app.route("/content/<originalSentence>/<wordCount>")
def languageHelp(originalSentence, wordCount):

    engine = pyttsx3.init()
    amountDefined = int(wordCount)
    tknzr = TweetTokenizer()
    inputSentence = re.sub(r'[^\w\s&&[^\']]','', originalSentence)

    inputSentence = re.sub(r'\d','', inputSentence)

    print(inputSentence)
    tokenizedInput = tknzr.tokenize(inputSentence)
    print(tokenizedInput)

    frequencyList = []

    for word in tokenizedInput:
        frequencyList.append(word_frequency(word, 'en'))


    hardWordsList = []

    for num in range(amountDefined):
        if tokenizedInput[frequencyList.index(min(frequencyList))] not in hardWordsList:
            hardWordsList.append(tokenizedInput[frequencyList.index(min(frequencyList))])
            frequencyList[frequencyList.index(min(frequencyList))] = 1

    print(hardWordsList)
    with open("DONOTSTAGE.json", "r") as apiLocation:
        config = json.load(apiLocation)

    client = OpenAI(
        # This is the default and can be omitted
        api_key=config['api_key'],
    )

    response = client.responses.create(
        model="gpt-4o",
        instructions="DO NOT USE MARKDOWN AT ALL. You are local friend that is helping a friend navigate your home country, you will be given words to define as short and simply as possible.",
        input="In the context of " + originalSentence + ", please define the words" + str(hardWordsList) + "SIMPLY and SHORTEN BUT NOT TOO MUCH and IGNORE NAMES and format it as DEFINED_WORD is DEFINITION",
    )

    print(response.output_text)
    tts = gTTS(response.output_text)
    tts.save("output.mp3")

    return send_file("output.mp3")










