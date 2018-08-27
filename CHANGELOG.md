#### 6.1.0 April 01 2017

- Use Cariam API in Stock Client

#### 6.0.0 March 21 2017

- Use Cariam API in Offers Client

#### 5.13.2 January 11 2017

- Fixed bug for invalid version name including price list date

#### 5.13.1 January 09 2017

- Fixed bug while loading cars list
- Added new offer categories to search criteria

#### 5.13.0 January 05 2017

- Use GUIDs in stock cars groups
- Feed list of sales versions in Offers from Cariam
- Avoid discounts on used cars
- Search offers, cars and groups on GUIDs
- Added 'Advance Invoiced' purchase status
- Added new Offer categories (Ex-LLD, Return, Company, Buyback)

#### 5.12.3 December 29 2016

- Add calculated french malus for december, 2016 as in 2017

#### 5.12.2 December 23 2016
    
- Add french ecology taxes for year 2017

#### 5.12.1 December 15 2016

- Fix deploy bug

#### 5.12.0 December 15 2016

- Add Guid identifier for compatybility with Cariam
- Make unique Guid identifier for cars versions
- Save registration data and number for offers pattern cars

#### 5.11.0 October 25 2016

- Add info about the dealers our supplier bought from
- Fix bug with entry minus offer sale net/gross price

#### 5.10.2 August 19 2016

- Fix bug with assigning a car to group if it's created as copy from other a car

#### 5.10.1 August 18 2016

- Fix bug with grouping cars by markets

#### 5.10.0 August 11 2016

- Assign sale markets for car
- Fix bug with display offer without category in customer orders views

#### 5.9.1 August 2 2016

- Show category of offers assigned to cars in readonly customer orders view

#### 5.9.0 July 27 2016

- Show category of offers assigned to cars in customer orders view

#### 5.8.0 July 22 2016

- Fix little bugs on UI for offers categories.
- Add offers categories changes to offer history
- Add registoration date to car history
- Search offers by categories
- Update DevExpress components to version 16.1.4

#### 5.7.0 July 08 2016

- support for edit category of offer in offer details view
- support for edit category of offer in multiedition view

#### 5.6.19 June 29 2016

- Change VAT rate for Latvia to 21%

#### 5.6.18 June 15 2016

- Fix bug on supply order (keeping together additional notes)

#### 5.6.17 May 11 2016

- Add body width with and without mirrors to Cars, Car Groups and Offers.
- Get Car Group data instead of Body and Version data when creating a new Offer.

#### 5.6.16 May 05 2016

- Change rates for LLD installments to 6,74% and to 5,79% for promo offers
- Add LLD values to offers history
- Update DevExpress components to version 5.2.9
- Fix error handling during supply order printing

#### 5.6.15 April 25 2016

- Remove flag "IsDemo" from car details view - from now on this flag will be set automatically in background.
- Add flag "IsCompanyCar" to car details view
- Add field "CompanyCarConditions" to car details view

#### 5.6.14 April 22 2016

- Fix Supply Order terms for Poland

#### 5.6.13 April 06 2016

- Add "Registration Agreed Date" to Purchase Order screen
- Add "Buyer And Supplier" value to Registrant enumeration

#### 5.6.12 April 05 2016

- Allow for saving Accepted Supply Orders with cars without Document conditions. 
- Validation error messages changed to warnings.

#### 5.6.11 March 30 2016

- Fixed too restrictive rules for Accepted Supply Orders with cars without Document conditions

#### 5.6.10 March 22 2016

- Accept suppliers orders if all assigned cars have documents conditions
- Save empty JSON documents as null
- Save power kw value for electrical and hybrid engines

#### 5.6.9 March 18 2016

- Fix path to nuget packages in CopyLibraries. 

#### 5.6.8 March 17 2016

- Set value of Ecobonus on Zero if tag "maluspaid" exists 

#### 5.6.7 March 0 2016

- Upgrade DevExpress libraries to version 15.2.7

#### 5.6.6 March 07 2016

- Fix "Object is currently in use elsewhere" bug.

#### 5.6.5 March 03 2016

- Fix show tags view on Offers details screen