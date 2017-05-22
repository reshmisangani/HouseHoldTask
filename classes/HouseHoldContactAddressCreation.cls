/***

Name: HouseHoldContactAddressCreation

Description:Need to store households(Account),contacts,mutiple addresses in salesforce.Exposing this class to via rest resource.

Created Date: 19th May 2017

***/


@RestResource(urlMapping='/HouseHoldContactAddressPost/*')

global class HouseHoldContactAddressCreation{

global static boolean erromessage=false;

//Parent Wrapper class to bind all the input parameters.
Global class AccountWrapper{
      Public String Name;
      public Contacts[] Contacts;
      public Addresses[] Address; 
     
      
      }
      
//To hold the contacts details       
Global class Contacts{
      Public String FirstName;
      Public String LastName;
     
      
      }
      

 // Responsewrapper hold the values to be returned.   
Global class ResponseWrapper{
        public String sStatus;
        public String message;
    } 
    
 Global class InSeasonWrapper{
        public String City;
        public String state;
        public String Country;
        public String Postalcode;
        public String street;
      
    }  
  
  
 // Post method which handles the creation of household, contacts, addresses in salesforce.         
@HttpPost
    global static ResponseWrapper AccInsert(AccountWrapper Request) {
    
     ResponseWrapper objRT = new ResponseWrapper();
     List<sObject> lstSobject = new List<sObject>();
     
     //Logic to check overlap dates
     Set<DateRange> ranges = new Set<DateRange>();
        for (Addresses ad: Request.address)
        {
            DateRange range = DateRange.factory(ad);
            if (ranges.contains(range))
                {erromessage=true;}
            else
                {ranges.add(range);}
        }
        
    try{
    
    if(erromessage){
    objRT.sStatus='success';
    objRT.message='Overlapping Dates are present, please rectify it and try agian';
    return objRT;
    
    }
    else{ 
    // Calling the findoutinseasonaddress for getting the in season address based upon the current date
    InSeasonWrapper insaddress=HouseHoldContactAddressCreation.findoutinseasonaddress(Request.address);
   
    //Logic for insertion of parent and child at same time
    Account acc=new account();
    if(insaddress!=null) {
    
    acc.name=Request.name;
    acc.billingcity=insaddress.city;
    acc.billingcountry=insaddress.country;
    acc.billingstreet=insaddress.street;
    acc.billingstate=insaddress.state;
    acc.billingpostalcode=insaddress.postalcode;
    insert acc;
    
    }
    else{acc=new account(name=Request.name);insert acc;}             
    
    
    for(contacts cc:Request.contacts){
    
    contact c=new contact();
    c.firstname=cc.firstname;
    c.lastname=cc.lastname;
    c.Accountid=acc.id;
    if(insaddress!=null){
    c.mailingcity=insaddress.city;
    c.mailingcountry=insaddress.country;
    c.mailingstreet=insaddress.street;
    c.mailingstate=insaddress.state;
    c.mailingpostalcode=insaddress.postalcode;
    
    }
    lstSobject.add(c);
    }
    
    for(Addresses addss:Request.Address){
    Address__c add=new Address__c();
    add.City__c=addss.City;
    add.Country__c=addss.Country;
    add.End_Date__c=Date.parse(addss.End_date);
    add.Postal__c=addss.postalcode;
    add.Street__c=addss.street;
    add.State__c=addss.state;
    add.Start_Date__c=Date.parse(addss.start_date);
    add.Account__c=acc.id;
    lstSobject.add(add);
    
    
    }
    
    // Create the account,contact and address.
        Database.SaveResult[] results = Database.insert(lstSobject);

    
    objRT.sStatus='Success';
    objRT.message='Request has been succesfully processesd';
    return objRT;
    }
    }
    
    
     catch (Exception e)
       {
        Error_Log__c log = new Error_Log__c();
        log.Request_Error_Source__c= 'REST API Call';
        log.Error_Message__c = '---------------------------------\n'+
           +e.getTypeName() + ' - ' + e.getMessage() + ' - ' + e.getStackTraceString();
        insert log;           
        objRT.message='Due to some reason we are unable to process your request,please try after sometime.Otherwise please reach out to us at householdintrgeation@issue.com';
        return objRT;
       }
    

    }
    
    
    //Method to find out the in season address by comparing the start and end date with system creation date.
    Public static InSeasonWrapper findoutinseasonaddress(List<Addresses> addWrapper){
    
    InSeasonWrapper inr=new InSeasonWrapper();
    for(Addresses addss:addWrapper){
    
    if(Date.valueOf(Date.parse(addss.start_date)) <= Date.valueOf(system.today()) && Date.valueOf(system.today()) <= Date.valueOf(Date.parse(addss.end_date))){
    
    inr.city=addss.city;
    inr.state=addss.state;
    inr.street=addss.street;
    inr.country=addss.country;
    inr.postalcode=addss.postalcode;
    
    
    }
    
    }
    return inr;
   }
    
}