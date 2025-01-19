import 'package:openid_client/openid_client_browser.dart';
import 'package:web/web.dart' hide Client;
// repo with information and documentation/demo code here available: https://github.com/appsup-dart/openid_client
// example code, taken from https://github.com/appsup-dart/openid_client/blob/master/example/browser_example/web/main.dart 

class kc_params {
  static const String URL = "https://cinecritique.mi.hdm-stuttgart.de/auth"; //TODO: Server URL
  static const String REALM = "movie-app";
  static const String CLIENT = "movie-app-client-frontend";
  static const String SCOPES = "profile";
  static const SCOPESL = ['profile']; //scopes (above) as list
}

//auth method
authenticate(Uri uri, String clientId, String scopes) async {   
    
    // create the client
    var issuer = await Issuer.discover(uri);
    var client = new Client(issuer, clientId);
    
    // create an authenticator
    var authenticator = new Authenticator(client, scopes: kc_params.SCOPESL);
    
    // get the credential
    var c = await authenticator.credential;
    
    if (c==null) {
      // starts the authentication
      authenticator.authorize(); // this will redirect the browser
    } else {
      // return the user info
      return await c.getUserInfo();
    }
}

Future<Authenticator> getAuthenticator() async {
  var uri = Uri.parse(kc_params.URL);
  var clientId = 'myclient';

  var issuer = await Issuer.discover(uri);
  var client = Client(issuer, clientId);

  return Authenticator(client, scopes: kc_params.SCOPESL);
}

Future<void> main() async {
  var authenticator = await getAuthenticator();

  var credential = await authenticator.credential;

  if (credential != null) {
    Future<void> refresh() async {
      var userData = await credential!.getUserInfo();
      document.querySelector('#name')!.text = userData.name!;
      document.querySelector('#email')!.text = userData.email!;
      document.querySelector('#issuedAt')!.text =
          credential!.idToken.claims.issuedAt.toIso8601String();
    }

    await refresh();
    (document.querySelector('#when-logged-in') as HTMLElement).style.display =
        'block';
    document.querySelector('#logout')!.onClick.listen((_) async {
      authenticator.logout();
    });
    document.querySelector('#refresh')!.onClick.listen((_) async {
      credential = await authenticator.trySilentRefresh();
      await refresh();
    });
  } else {
    (document.querySelector('#when-logged-out') as HTMLElement).style.display =
        'block';
    document.querySelector('#login')!.onClick.listen((_) async {
      authenticator.authorize();
    });
  }
}