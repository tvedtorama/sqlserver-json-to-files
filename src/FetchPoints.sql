/* Union terminal, points and point children into point hierarchy */
WITH AccessPoint (Id, bossIdId, Guid, IDPunktType, IDFraksjon, IDPunktEgenskap, IDPunktKundeTyper, ServiceGuid, ServiceId, ServiceRef, ParentId, tag, name, description, geoLocation, status, oldCustomerFn) 
	  AS (
	     SELECT CAST(IDPunkt as nvarchar(200)) as ID, IDPunkt as bossIdId, GUIDPunkt as Guid, IDPunktType, IDFraksjon, IDPunktEgenskap, IDPunktKundeTyper, P.TjenesteGuidPunkt as ServiceGuid, P.TjenesteIdPunkt as ServiceId, P.TjenesteReferanse as ServiceRef, 'S' + CAST(IDTjeneste as nvarchar(200)) as ParentId, CASE WHEN P.Merkelapp = 'NA' THEN NULL ELSE P.Merkelapp END as tag, Navn as name, Beskrivelse as description, (SELECT p2.UtmSone as utmZone, p2.UtmX as utmX, p2.UtmY as utmY, p2.GPS as gps, p2.DesimalGrader as decimalDegrees FROM [BossID].[dbo].Punkt P2 WHERE P2.IDPunkt = P.IDPunkt FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER) AS geoLocation, 'Active' AS status, null AS oldCustomerFn FROM [BossID].[dbo].Punkt P WHERE Slettet <> 1
		 UNION
		 SELECT 'C' + CAST(IDPunktBarn as nvarchar(200)) AS ID, IDPunktBarn as bossIdId, NULL as Guid, IDPunktType, IDFraksjon, IDPunktEgenskap, IDPunktKundeTyper, PB.TjenesteGuidPunkt as ServiceGuid, PB.TjenesteIdPunkt as ServiceId, PB.TjenesteReferanse AS ServiceRef, CASE WHEN PB.IDPunktFar IS NULL THEN CAST(PB.IDPunkt as nvarchar(200)) ELSE 'C' + CAST(IDPunktFar as nvarchar(200)) END, NULL as tag, NULL as Name, null as description, NULL as geoLocation, 'Active' AS status, null AS oldCustomerFn FROM [BossID].[dbo].PunktBarn PB WHERE Slettet <> 1
		 UNION
		 SELECT 'S' + CAST(IDTjeneste as nvarchar(200)) as ID, IDTjeneste as bossIdId, GUIDTjeneste as Guid, 10 as IDPunktType, 1 as IDFraksjon, 0 as IDPunktEgenskap, 0 as IDPunktKundeTyper, null as ServiceGuid, null as ServiceId, '' as ServiceRef, '' as ParentID, NULL as tag, Navn as Name, Beskrivelse as description, NULL as geoLocation, CASE WHEN ServiceStatus = 1 THEN 'Active' ELSE 'Inactive' END AS status, CASE WHEN I3&128 = 0 THEN 1 ELSE 0 END AS oldCustomerFn FROM [BossID].[dbo].BossIDTjeneste WHERE Slettet <> 1
	  )
	  SELECT id as accessPointId, parentId as parentId, name, description,
	  CASE WHEN PT.KortNavn = 'NEDPUNKT' THEN 'ACCESS_PARENT' WHEN PT.KortNavn = 'NEDKAST' THEN 'ACCESS_POINT' WHEN PT.KortNavn = 'GRUPPE' THEN 'GROUP' ELSE 'TERMINAL' END as type,
	  guid as 'externalKeys.guid',
	  ServiceGuid as 'externalKeys.serviceGuid',
	  ServiceId as 'externalKeys.serviceId',
	  bossIdId as 'externalKeys.bossId',
	  tag as 'externalKeys.printedTag',
	  CASE WHEN FT.IDFraksjon >= 1 THEN FT.FraksjonID ELSE NULL END AS 'properties.fraction',
	  CASE WHEN FT.IDFraksjon >= 1 THEN FT.Navn ELSE NULL END AS 'properties.fractionDesc',
	  PE.KortNavn AS 'properties.hatchTypeCode',
	  PKT.KortNavn AS 'properties.customerType',
	  BS.APINokkel AS 'properties.apiKey',
	  BS.ServiceURL AS 'properties.serviceUrl',
	  BS.Service AS 'properties.serviceType',
	  BS.ServiceBinding AS 'properties.serviceBinding',
	  BT.navn AS 'properties.RFIDReadFormat', 
	  oldCustomerFn AS 'properties.oldCustomerFn',
	  JSON_QUERY(geoLocation) AS geoLocation,
	  status as 'status'
	  FROM AccessPoint AP
	  INNER JOIN [BossID].[dbo].FraksjonsType FT ON ft.IDFraksjon = AP.IDFraksjon
	  INNER JOIN [BossID].[dbo].PunktEgenskap PE ON PE.IDPunktEgenskap = AP.IDPunktEgenskap
	  LEFT OUTER JOIN [BossID].[dbo].PunktType PT ON pt.IDPunktType = AP.IDPunktType -- Note: "terminal" = hardcoded to 10 above
	  LEFT OUTER JOIN [BossID].[dbo].BossIDTjeneste BS ON BS.IDTjeneste = AP.bossIdId AND AP.IDPunktType = 10
	  LEFT OUTER JOIN [BossID].[dbo].BrikkeTyper BT ON BT.IDBrikkeType = BS.IDBrikkeType AND AP.IDPunktType = 10
	  LEFT OUTER JOIN [BossID].[dbo].PunktKundeType PKT ON PKT.IDPunktKundeTyper=AP.IDPunktKundeTyper
      -- WHERE ParentId = '28' OR Id = '28' 
	  FOR JSON PATH
