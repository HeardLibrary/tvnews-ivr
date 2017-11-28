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
    
declare function twilio:answer-phone() {
      <Response>
    	<Say>Welcome to the Vanderbilt Television News Archive.</Say>
        {twilio:main-options()}
      </Response>	
};

declare function twilio:main-options() {
    <Gather action="/twilio/gather" method="GET" timeout="10">
    	<Say>For questions about ordering video or the status of an existing order, please press 1 followed by the #.</Say>
    	<Say>To arrange a research consultation or to schedule a visit, please press 2 followed by the #.</Say>
    	<Say>To inquire about sponsorship or to become an institutional sponsor, please press 3 followed by the #.</Say>
    	<Say>To report technical difficulties with the website or collection, please press 4 followed by the #.</Say>
    	<Say>To contact a particular member of the archive's staff, please press 5 followed by the #.</Say>
    	<Say>To hear these options again, please press * followed by the #.</Say>
    </Gather>
};

declare function twilio:gather-call-list($digits as xs:string) as element() {
    if ($digits = fn:doc("Twilio/ids.xml")//contacts:phone/@option/fn:data()) then
        let $name := fn:doc("Twilio/ids.xml")//contacts:phone[@option = $digits]/contacts:name/text()
        let $phone-number := fn:doc("Twilio/ids.xml")//contacts:phone[@option = $digits]/@number/fn:data()
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
        {for $person in fn:doc("Twilio/ids.xml")//contacts:phone
         return <Say>{$person/@option/data()} followed by the # for {$person/contacts:name/text()}</Say>}
         <Say>Please press * followed by the # to hear these options again.</Say>
         <Say>To return to the main menu, please press 0 followed by the #.</Say>
    </Gather>
};

declare function twilio:direct-outbound($digits as xs:string?) as element(Response) {
        switch ($digits)
        case "*" return <Response>{twilio:main-options()}</Response>
        case "1" return <Response>{twilio:make-call("+16153438042")}</Response>
        case "2" return <Response>{twilio:make-call("+16153222187")}</Response>
        case "3" return <Response>{twilio:make-call("+16153222187")}</Response>
        case "4" return <Response>{twilio:make-call("+16153437015")}</Response>
        case "5" return <Response>{twilio:list-staff()}</Response>
        default return  <Response>
                            <Say>Sorry! I did not recognize your selection.</Say>
                            {twilio:main-options()}
                        </Response>
            
};
