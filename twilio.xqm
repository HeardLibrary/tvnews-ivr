xquery version "3.1";

module namespace twilio = "http://www.library.vanderbilt.edu/modules/twilio";

declare namespace contacts = "http://www.library.vanderbilt.edu/modules/twilio/contacts";
declare namespace auth = "http://www.library.vanderbilt.edu/modules/twilio/auth";

declare variable $twilio:userName as xs:string :=
    fn:string(fn:doc("Twilio/auth.xml")//auth:userName/text());
declare variable $twilio:password as xs:string :=
    fn:string(fn:doc("Twilio/auth.xml")//auth:password/text());
declare variable $twilio:phoneNumber as xs:string :=
    fn:string(fn:doc("Twilio/auth.xml")//auth:phoneNumber/text());

declare variable $twilio:ids :=
	<ids>
      <phone number="+16153226938" option="1">
      	<name>Clifford Anderson</name>
      </phone>
      <phone number="+16153437432" option="2">
      	<name>Dana Currier</name>
      </phone>
      <phone number="+16153437015" option="3">
      	<name>Steve Davis</name>
      </phone>
      <phone number="+16153222187" option="4">
      	<name>Susan Grider</name>
      </phone>
      <phone number="+16153437433" option="5">
      	<name>Russ Mason</name>
      </phone>
      <phone number="+16153438042" option="6">
      	<name>Lara McClintock</name>
      </phone>
      <phone number="+16153437430" option="7">
      	<name>Skip Pfeiffer</name>
      </phone>
    </ids>;

declare function twilio:answer-phone() {
      <Response>
    	<Play>/static/welcome.mp3</Play>
        {twilio:main-options()}
        <Redirect method="GET">
        	/twilio/gather
    	</Redirect>
      </Response>
};

declare function twilio:main-options() {
    <Gather action="/twilio/gather" method="GET" timeout="10">
    	<Play>/static/options.mp3</Play>
    </Gather>
};

declare function twilio:gather-call-list($digits as xs:string) as element() {
    if ($digits = $twilio:ids/phone/@option/fn:data()) then
        let $name := $twilio:ids/phone[@option = $digits]/name/text()
        let $phone-number := $twilio:ids/phone[@option = $digits]/@number/fn:data()
    return
        <Response>
             <Say>Calling {$name}</Say>
             {twilio:make-call($phone-number)}
        </Response>
    else if ($digits = "0") then
          <Response>{twilio:main-options()}</Response>
    else
        <Response>{twilio:list-staff()}</Response>
};

declare function twilio:make-call($phone-number) {
    <Dial timeout="20" record="false">{$phone-number}</Dial>
};

declare function twilio:list-staff() as element() {
    <Gather action="/twilio/gather/staff" method="GET" timeout="10">
       <Say>Please enter</Say>
        {
        	let $ids := $twilio:ids
            for $person in $ids/phone
        	return (
            	<Say>{$person/@option/data()}</Say>,
        		<Say>followed by the # for</Say>,
        		<Say>{$person/name/text()}</Say>
           	)
        }
        <Say>Please press * followed by the # to hear these options again.</Say>
        <Say>To return to the main menu, please press 0 followed by the #.</Say>
    </Gather>
};

declare function twilio:direct-outbound($digits as xs:string?) as element(Response) {
        switch ($digits)
        case "*" return <Response>{twilio:main-options()}</Response>
        case "1" return <Response>{twilio:make-call("+16153438042")}</Response>
        case "2" return <Response>{twilio:make-call("+16153437015")}</Response>
        case "3" return <Response>{twilio:make-call("+16153222187")}</Response>
        case "4" return <Response>{twilio:make-call("+16153437015")}</Response>
        case "5" return <Response>{twilio:list-staff()}</Response>
        default return  <Response>
                            <Play>/static/sorry.mp3</Play>
                            {twilio:main-options()}
                        </Response>

};
