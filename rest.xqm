xquery version "3.1";

(:~
 : This module uses RESTXQ annotations to direct Twilio calls
 : @author Clifford Anderson
 :)

module namespace page = 'http://www.library.vanderbilt.edu/modules/twilio/restxq';
import module namespace twilio = 'http://www.library.vanderbilt.edu/modules/twilio' at 'twilio.xqm';

(:~
 : This function answers Twilio calls.
 : @param $name string to be included in the welcome message
 : @return Response element 
 :)
declare
  %rest:path("/twilio/answer")
  %rest:GET
  function page:answer-phone()
    as element(Response)
{
    twilio:answer-phone()
};

(:~
 : This function handles digits for the main menu
 : @param $digits integer(s) provided by caller
 : @return Response element 
 :)
declare
  %rest:path("/twilio/gather")
  %rest:query-param("Digits", "{$digits}")
  %rest:GET
  function page:gather-digits(
    $digits as xs:string?)
    as element(Response)
{
    twilio:direct-outbound($digits)
};

(:~
 : This function handles digits for the staff menu.
 : @param $digits integer(s) provided by caller
 : @return Response element 
 :)
declare
  %rest:path("/twilio/gather/staff")
  %rest:query-param("Digits", "{$digits}")
  %rest:GET
  function page:gather-staff-digits(
    $digits as xs:string?)
    as element()
{
    twilio:gather-call-list($digits)
};

(:~
 : This function concludes Twilio calls.
 : @return Response element 
 :)
declare
  %rest:path("/twilio/goodbye")
  %rest:POST
  function page:goodbye()
    as element(Response)
{
  <Response>
    <Say>Goodbye! I hope you have a lovely day.</Say>
  </Response>
};
