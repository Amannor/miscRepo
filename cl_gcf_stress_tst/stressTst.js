const loadtest = require('loadtest');
console.log("Starting");


const payloadToSendObj = {
      "input":"[%IF:EMAIL=='roman_y@optimove.com'%]Msg for RomanY[%END:IF%] b [%ELSE%] General message [%END:IF%] [%ELSE%] General message (ii) [%END:IF%]  [%ELSE%] General message (iii) [%END:IF%]",
      "shouldValidate":"true",
       "attrs":{    "[%EMAIL%]": "alon_m@optimove.com"  }
      }; 

let payloadToSend = JSON.stringify(payloadToSendObj);


function statusCallback(error, result, latency) {
    console.log('Current latency %j, result %j, error %j', latency, result, error);
    console.log('----');
    console.log('Request elapsed milliseconds: ', result.requestElapsed);
    console.log('Request index: ', result.requestIndex);
    console.log('Request loadtest() instance index: ', result.instanceIndex);
}


const options = {
//    url: 'https://us-central1-optimail-conditional-language.cloudfunctions.net/api/translate',
    url: 'https://us-central1-optimail-conditional-language.cloudfunctions.net/tstFunc2',
    maxRequests: 2,
    //concurrency: 10,
    method: 'POST',
    body: payloadToSend,
    statusCallback: statusCallback,
    headers: 
	{
		'Content-Type': 'application/json',
		'Content-Length': payloadToSend.length,
		'Cache-Control': 'no-cache'
	},
   contentType: 'application/json'

};

loadtest.loadTest(options, function(error, result)
{
    if (error)
    {
        return console.error('Got an error: %s', error);
    }else{
	    console.log("It worked!");
    }
    //console.log("result keys" + Object.keys(result));
    console.log('result %j', result);
    console.log('Tests run successfully');
});
