unit uHTTP;

interface
uses
  {$IFDEF DEBUG} CodeSiteLogging, {$ENDIF}
  Windows,SysUtils, Variants, Classes, forms, StdCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, StrUtils,ActiveX, ComObj, MSXML2_TLB,
  Types,IdMultipartFormData,IdGlobalProtocols, IdSSLOpenSSL, IdURI,
  IdAuthentication,IdAuthenticationManager, IdAuthenticationDigest,IdAuthenticationNTLM,
  IdAllAuthentications,uOptions;

type
  TWebHTTP = class(TObject)
    procedure ProxyAuthorization(Sender: TObject; Authentication: TIdAuthentication; var Handled: Boolean);
    function  GetProtocol(const aURL : string) : string;
    function  GetWebList(const aURL, aUserID, aPwd : string; var URLArray : TStringDynArray; Combo : TComboBox; Options : TWebGUIOptions) : Boolean;
    function  GetURLResponse(const aURL,aUserName, aPassword, ResponseType : string; Options : TWebGUIOptions) : string;
    function  CreateHTTPObject(const aURL, aUserName, aPassword : string; Options : TWebGUIOptions) : TIdHTTP;
    function  PostURL(const aURL, aUserName, aPassword : string; Params : TStringList; Options : TWebGUIOptions) : string;
    function  CreateAlbum(const aURL : string; aAllowOthers : Boolean; const  aUserName, aPassword, aAlbum : string; var URLArray : TStringDynArray; Combo : TComboBox; Options : TWebGUIOptions) : Boolean;
    function  PostPicture(const aURL,aUserName,aPassword,aPicFile : string; Options : TWebGUIOptions) : Boolean;
    procedure DisplayError(const aError : string);
  private
    procedure Redirect(Sender: TObject; var dest: string;
      var NumRedirect: Integer; var Handled: Boolean; var VMethod: string);
  end;

const
  urlGetGalleries = '?op=findAssets;className=WebGUI::Asset::Wobject::Gallery;as=xml';
  urlGetAlbums    = '?op=findAssets;className=WebGUI::Asset::Wobject::GalleryAlbum;as=xml';

implementation
uses uFuncs;

/// <summary>
/// This event is fired when the TIdHTTP component requires authenication from the proxy
/// </summary>
/// <param name="Sender"> TObject </param>
/// <param name="Authentication"> TIdAuthentication </param>
/// <param name="Handled"> var - Boolean </param>
procedure TWebHTTP.ProxyAuthorization(Sender: TObject; Authentication: TIdAuthentication; var Handled: Boolean);
var
  usr : Widestring;
  pwd : Widestring;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( 'ProxyAuthorization' );{$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('Sender',Sender); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('Authentication',Authentication as TIdNTLMAuthentication); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('Authentication.ClassName',Authentication.ClassName); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('Authentication.Authentication',Authentication.Authentication); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('Authentication.AuthParams',Authentication.AuthParams); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('Authentication.Params',Authentication.Params); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('Authentication.Steps',Authentication.Steps); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('Authentication.CurrentStep',Authentication.CurrentStep); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('authentication set'); {$ENDIF}
  If GetUserCredentials(Application.Handle,'Proxy Authentication',(Sender as TIdHTTP).ProxyParams.ProxyServer,usr,pwd) then
    begin
      Authentication.Username := usr;
      Authentication.Password := pwd;
      {$IFDEF DEBUG} CodeSite.Send('Authentication.AuthParams',Authentication.AuthParams); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('Authentication.Params',Authentication.Params); {$ENDIF}
      Handled := TRUE;
    end
  else
    Handled := FALSE;

  {$IFDEF DEBUG}CodeSite.ExitMethod('ProxyAuthorization' );{$ENDIF}
end;

/// <summary>
/// Create SSL handler if required during a redirect
/// </summary>
procedure TWebHTTP.Redirect(Sender: TObject; var dest: string;
  var NumRedirect: Integer; var Handled: Boolean; var VMethod: string);
begin
  if (AnsiSameText(GetProtocol(dest),'https')) and (not ((Sender as TIdHTTP).IOHandler is TIdSSLIOHandlerSocketOpenSSL)) then
    begin
      (Sender as TIdHTTP).IOHandler.Free;
      (Sender as TIdHTTP).IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(Application);
    end;
end;


/// <summary>
/// Gets the protocol from the URL, if not specified assumes HTTP
/// </summary>
/// <param name="aURL"> URL </param>
/// <returns>string - returns protocol</returns>
function TWebHTTP.GetProtocol(const aURL : string) : string;
var
  i: Integer;
begin
  i := Pos(':',aURL);
  if i > 0 then
    Result := Copy(aURL,1,i-1)
  else
    Result := 'http';
end;

/// <summary>
/// Creates and configures the TidHTTP object
/// </summary>
/// <param name="aURL"> URL to get/post </param>
/// <param name="aUserName"> Username for URL, if required </param>
/// <param name="aPassword"> Password for URL, if required </param>
/// <param name="Options"> TWebGUIOptions </param>
/// <returns>TIdHTTP - returns configured object</returns>
function TWebHTTP.CreateHTTPObject(const aURL, aUserName, aPassword : string; Options : TWebGUIOptions) : TIdHTTP;
var
  prt : string;
begin
  Result := TIdHTTP.Create(nil);
  Result.HTTPOptions := [hoInProcessAuth,hoForceEncodeParams];

  Result.HandleRedirects := TRUE;
  Result.OnRedirect := Redirect;
  prt := GetProtocol(aUrl);
  // Handle SSL (https)
  if AnsiSameText(prt,'https') then
    begin
      // Uses dlls from http://www.slproweb.com/products/Win32OpenSSL.html
      Result.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(Application);
    end;

  // Handle Proxy
  if Options.ProxyUse then
    begin
      Result.OnProxyAuthorization := ProxyAuthorization;
      Result.ProxyParams.ProxyServer := Options.ProxyServer;
      Result.ProxyParams.ProxyPort := Options.ProxyPort;
      Result.Request.ProxyConnection := 'KEEP-ALIVE';
    end;

  if aUserName = '' then
    Result.Request.BasicAuthentication := False
  else
    begin
      Result.Request.BasicAuthentication := TRUE;
      Result.Request.Username := aUserName;
      Result.Request.Password := aPassword;
    end;
  {$IFDEF DEBUG} CodeSite.Send('Request',Result.Request); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('Request.BasicAuthentication',Result.Request.BasicAuthentication); {$ENDIF}

end;

/// <summary>
/// Call GET on URL and return the result
/// </summary>
/// <param name="aURL"> URL to get. </param>
/// <param name="aUserName"> Username for URL, if required </param>
/// <param name="aPassword"> Password for URL, if required </param>
/// <param name="ResponseType"> Type of response expected, if not specified type, returns blank. </param>
/// <param name="Options"> TWebGUIOptions </param>
/// <returns>String - returns results of Get</returns>
function TWebHTTP.GetURLResponse(const aURL,aUserName, aPassword, ResponseType : string; Options : TWebGUIOptions) : string;
var
  HC : TIdHTTP;
  sResponse: string;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( 'GetURLResponse' );{$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('aURL',aURL); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('aUserName',aUserName); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('aPassword',aPassword); {$ENDIF}
  HC := CreateHTTPObject(aURL,aUserName,aPassword,Options);
  try
    try
      sResponse := HC.Get(TidUri.URLEncode(aURL));
      {$IFDEF DEBUG} CodeSite.Send('HC',HC); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('sResponse',sResponse); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('HC.Response',HC.Response); {$ENDIF}
      if AnsiContainsText(HC.Response.CacheControl,'revalidate') then
        raise Exception.Create('Incorrect username or password')
      else
        if (ResponseType = '') or (AnsiSameText(ResponseType,HC.Response.ContentType)) then
          Result := sResponse
        else
          Result := '';
    except
      on e : Exception do
        begin
          {$IFDEF DEBUG} CodeSite.SendException(e); {$ENDIF}
          case HC.ResponseCode of
            302 : e.Message := 'Could not find '+HC.Request.Host;
          end;
          raise;
        end;
    end;
  finally
    FreeAndNil(HC);
  end;

  {$IFDEF DEBUG}CodeSite.ExitMethod('GetURLResponse');{$ENDIF}
end;


/// <summary>
/// Gets a list from the web site and populates the combobox
/// </summary>
/// <param name="aURL"> URL to query </param>
/// <param name="aUserID"> User ID for site </param>
/// <param name="aPwd"> Password for site </param>  k
/// <param name="URLArray"> Dynamic string array, URLs that link to the names will be placed here </param>
/// <param name="Combo"> Combobox to insert the names into </param>
/// <param name="Options"> TWebGUIOptions </param>
function TWebHTTP.GetWebList(const aURL, aUserID, aPwd : string; var URLArray : TStringDynArray; Combo : TComboBox; Options : TWebGUIOptions) : Boolean;
const
  MaxCount = 100;
  PgParam = ';pn=';
var
  sXML : string;
  xDoc : IXMLDOMDocument2;
  xnlGallery : IXMLDOMNodeList;
  xnTest : IXMLDOMNode;
  I: Integer;
  iPage : integer;
  sURL : string;
  bRes : Boolean;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( 'GetGalleryList' );{$ENDIF}
  iPage := 1;
  Combo.Clear;
  Result := FALSE;
  // cycle through pages until complete
  repeat
    if iPage > 1 then
      sURL := aURL+PgParam+IntToStr(iPage)
    else
      sURL := aURL;
    {$IFDEF DEBUG} CodeSite.Send('sURL',sURL); {$ENDIF}
    sXML := GetURLResponse(sURL,aUserID,aPwd,'text/xml',Options);
    if sXML <> '' then
      begin
        {$IFDEF DEBUG} CodeSite.Send('sXML',sXML); {$ENDIF}
        xDoc := CreateOleObject('Microsoft.XMLDOM') as IXMLDomDocument2;
        xDoc.setProperty('SelectionLanguage', 'XPath'); // needs to be set otherwise starts-with doesn't work
        xDoc.async := FALSE;
        bRes := TRUE;
        {$IFDEF DEBUG} CodeSite.Send('loading file'); {$ENDIF}
        // Does this need to be handled if loading fails?
        If xDoc.loadXML(sXML) then
          begin
            {$IFDEF DEBUG} CodeSite.Send('file loaded'); {$ENDIF}
            xnlGallery := xDoc.documentElement.selectNodes('/opt/assets');
            if (xnlGallery <> nil) and (xnlGallery.length > 0) then
              begin
                Result := True;
                {$IFDEF DEBUG} CodeSite.Send('xnlLang.length',xnlGallery.length); {$ENDIF}
                if iPage > 1 then
                  SetLength(URLArray,xnlGallery.length+Length(URLArray))
                else
                  SetLength(URLArray,xnlGallery.length);

                for I := 0 to xnlGallery.length - 1 do
                  begin
                    xnTest := xnlGallery.item[i];
                    URLArray[i] := xnTest.selectSingleNode('descendant::url').text;
                    Combo.AddItem(xnTest.selectSingleNode('descendant::title').text,TObject(i));
                    {$IFDEF DEBUG} CodeSite.Send('Title',xnTest.selectSingleNode('descendant::title').text); {$ENDIF}
                    {$IFDEF DEBUG} CodeSite.Send('URL',xnTest.selectSingleNode('descendant::url').text); {$ENDIF}
                  end;
              end;
          end
        else
          bRes := FALSE;
        {$IFDEF DEBUG} CodeSite.Send('bRes',bRes); {$ENDIF}
        Inc(iPage);
      end
    else
      bRes := FALSE;
  until (not bRes) or (xnlGallery.length < MaxCount);
  {$IFDEF DEBUG}CodeSite.ExitMethod( 'GetGalleryList' );{$ENDIF}
end;

/// <summary>
/// POST to the URL
/// </summary>
/// <param name="aURL"> URL to get. </param>
/// <param name="aUserName"> Username for URL, if required </param>
/// <param name="aPassword"> Password for URL, if required </param>
/// <param name="Params"> Parameters for the post </param>
/// <param name="Options"> TWebGUIOptions </param>
/// <returns>String - returns results of POST. If responsecode is not 201 then returns "invalid" </returns>
function TWebHTTP.PostURL(const aURL, aUserName, aPassword : string; Params : TStringList; Options : TWebGUIOptions) : string;
var
  HC : TIdHTTP;
  sResponse: string;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod('PostURL' );{$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('aURL',aURL); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('aUserName',aUserName); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('aPassword',aPassword); {$ENDIF}
  HC := CreateHTTPObject(aURL,aUserName,aPassword,Options);
  try
    try
      sResponse := HC.Post(TidUri.URLEncode(aURL),Params);
      {$IFDEF DEBUG} CodeSite.Send('HC',HC); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('HC.ResponseCode',HC.ResponseCode); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('HC.ResponseText',HC.ResponseText); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('sResponse',sResponse); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('HC.Response',HC.Response); {$ENDIF}
      if AnsiContainsText(HC.Response.CacheControl,'revalidate') then
        raise Exception.Create('Incorrect username or password')
      else
        if HC.ResponseCode = 201 then
          Result := sResponse
        else
          Result := 'invalid'
    except
      on e : Exception do
        begin
          {$IFDEF DEBUG} CodeSite.SendException(e); {$ENDIF}
          case HC.ResponseCode of
            302 : e.Message := 'Could not find '+HC.Request.Host;
          end;
          raise;
        end;
    end;
  finally
    FreeAndNil(HC);
  end;

  {$IFDEF DEBUG}CodeSite.ExitMethod('PostURL' );{$ENDIF}
end;

/// <summary>
/// Creates a new Album
/// </summary>
/// <param name="aURL"> URL to query </param>
/// <param name="aAllowOthers"> Allow others to post </param>
/// <param name="aUserName"> User ID for site </param>
/// <param name="aPassword"> Password for site </param>
/// <param name="aAlbum"> Name of Album to create </param>
/// <param name="URLArray"> Dynamic string array, URLs that link to the names will be placed here </param>
/// <param name="Combo"> Combobox to insert the names into </param>
/// <param name="Options"> TWebGUIOptions </param>
/// <returns>Boolean - Returns TRUE if successful album creation</returns>
function TWebHTTP.CreateAlbum(const aURL : string; aAllowOthers : Boolean; const aUserName, aPassword, aAlbum : string; var URLArray : TStringDynArray; Combo : TComboBox; Options : TWebGUIOptions) : Boolean;
var
  Params : TStringList;
  sXML: string;
  xDoc : IXMLDOMDocument2;
  xnAlbum : IXMLDOMNode;
  i: Integer;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod( Self, 'CreateAlbum' );{$ENDIF}
  Result := False;
  Params := TStringList.Create;
  // can't encode the album name or it gets set that way
  Params.Add(TIdURI.ParamsEncode('func=addAlbumService;as=xml;othersCanAdd='+IntToStr(Ord(aAllowOthers))+';title=')+aAlbum);
  sXML := PostURL(aURL,aUserName,aPassword,Params,Options);
  {$IFDEF DEBUG} CodeSite.Send('sXML',sXML); {$ENDIF}
  if sXML = 'invalid' then
    DisplayError('Cannot create album. Either you do not have access or unknown error occurred.')
  else
    begin
      xDoc := CreateOleObject('Microsoft.XMLDOM') as IXMLDomDocument2;
      xDoc.setProperty('SelectionLanguage', 'XPath'); // needs to be set otherwise starts-with doesn't work
      xDoc.async := FALSE;
      If xDoc.loadXML(sXML) then
        begin
          {$IFDEF DEBUG} CodeSite.Send('xml loaded'); {$ENDIF}
          xnAlbum := xDoc.documentElement.selectSingleNode('/opt');
          SetLength(URLArray,Length(URLArray)+1);
          i := High(URLArray);
          URLArray[i] := xnAlbum.selectSingleNode('descendant::url').text;
          Combo.AddItem(xnAlbum.selectSingleNode('descendant::title').text,TObject(i));
          Result := True;
        end
      else
        DisplayError('Error loading album information from web page.');
    end;

  FreeAndNil(Params);
  {$IFDEF DEBUG} CodeSite.Send('Result',Result); {$ENDIF}
  {$IFDEF DEBUG}CodeSite.ExitMethod( Self, 'CreateAlbum' );{$ENDIF}
end;

/// <summary>
/// Post Picture to the site
/// </summary>
/// <param name="aURL"> URL to get. </param>
/// <param name="aUserName"> Username for URL, if required </param>
/// <param name="aPassword"> Password for URL, if required </param>
/// <param name="aPicFile"> Picture file name to upload </param>
/// <param name="Options"> TWebGUIOptions </param>
/// <returns>Boolean - returns TRUE if picture posted</returns>
function TWebHTTP.PostPicture(const aURL,aUserName,aPassword,aPicFile : string; Options : TWebGUIOptions) : Boolean;
var
  HC : TIdHTTP;
  sResponse: string;
  PicData : TIdMultiPartFormDataStream;
begin
  {$IFDEF DEBUG}CodeSite.EnterMethod('PostPicture' );{$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('aURL',aURL); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('aUserName',aUserName); {$ENDIF}
  {$IFDEF DEBUG} CodeSite.Send('aPassword',aPassword); {$ENDIF}
  Result := FALSE;
  PicData := TIdMultiPartFormDataStream.Create;
  PicData.AddFile('file',aPicFile,GetMIMETypeFromFile(aPicFile));
  PicData.AddFormField('func','addFileService');
  PicData.AddFormField('as','xml');
  { TODO -cPost Picture : Figure out if it is possible to extract the Picasa caption name from the picture }
  PicData.AddFormField('title',ExtractFileName(aPicFile));

  HC := CreateHTTPObject(aURL,aUserName,aPassword,Options);
  try
    {$IFDEF DEBUG} CodeSite.Send('HC.Request',HC.Request); {$ENDIF}
    {$IFDEF DEBUG} CodeSite.Send('HC.Request.BasicAuthentication',HC.Request.BasicAuthentication); {$ENDIF}
    try
      HC.Request.ContentType := PicData.RequestContentType;

      sResponse := HC.Post(TidUri.URLEncode(aURL),PicData);
      {$IFDEF DEBUG} CodeSite.Send('HC',HC); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('HC.ResponseCode',HC.ResponseCode); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('HC.ResponseText',HC.ResponseText); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('sResponse',sResponse); {$ENDIF}
      {$IFDEF DEBUG} CodeSite.Send('HC.Response',HC.Response); {$ENDIF}
      if AnsiContainsText(HC.Response.CacheControl,'revalidate') then
        raise Exception.Create('Incorrect username or password')
      else
        if HC.ResponseCode = 201 then
          Result := TRUE
        else
          raise Exception.Create('Error uploading picture "'+aPicFile+'". Either you do not have access or unknown error occurred. (Response: '+IntToStr(HC.ResponseCode)+')');
    except
      on e : Exception do
        begin
          {$IFDEF DEBUG} CodeSite.SendException(e); {$ENDIF}
          case HC.ResponseCode of
            302 : e.Message := 'Could not find '+HC.Request.Host;
          end;
          raise;
        end;
    end;
  finally
    FreeAndNil(HC);
    FreeAndNil(PicData);
   end;
  {$IFDEF DEBUG} CodeSite.ExitMethod('PostPicture'); {$ENDIF}
end;

/// <summary>
/// Displays error messages
/// </summary>
/// <param name="aError"> Error message </param>
procedure TWebHTTP.DisplayError(const aError : string);
begin
  MessageBox(Application.Handle,PChar(aError) ,
           PChar(Application.Title), MB_OK+MB_ICONSTOP);
end;

end.

