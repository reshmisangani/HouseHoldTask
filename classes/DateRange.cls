/***

Name: DateRange

Description:This class has been used in HouseHoldContactAddressCreation.Class Specifically used to check for overlappinf date in addresses.


Created Date: 20th May 2017

***/
global class DateRange
   {
    final Date startDate, endDate;
    public DateRange(Date startDate, Date endDate)
    {
        this.startDate = startDate;
        this.endDate = endDate;
    }
    public Integer hashCode() { return 1; }
    public Boolean equals(Object instance)
    {
        DateRange that = (DateRange)instance;
        return startDate <= that.endDate && endDate >= that.startDate;
    }

    public static DateRange factory(Addresses record)
    {
        return new DateRange(date.parse(record.Start_date), date.parse(record.End_date));
    }
    
    
     

  }