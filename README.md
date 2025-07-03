# ⚠️⚠️⚠️ This is merely a port of a project I've worked on from our universitys GitLab ⚠️⚠️⚠️

# Cinecritique Frontend

Das Flutter Frontend für CineCritique

# Inhalt
1. Starten der App und Voraussetzungen
    - Voraussetzungen
    - Starten der App
    - Mobile App
2. Versionlog

## Starten der App und Voraussetzungen
Empgehlung: [Live Version im Web](https://cinecritique.mi.hdm-stuttgart.de/) benutzen, lokal kann Keycloak Probleme machen. Beispielnutzer für die Web Version: ``johndoe``mit Passwort ``123``
### Voraussetzungen
1. Lokale Flutter Installation (inkl. Dependencies wie Chrome webtools)
2. Keycloak Installation
3. Backend Service und AI Service

Anmerkung für Keycloak:
Wenn das Projekt lokal laufen soll, muss man in der ``auth.dart`` die ``redirectUri`` auf ``http://localhost:54841``, und das Projekt mit ``flutter run -d chrome --web-port=54841``starten

### Starten der App
1. Navigiere in Projektverzeichnis (``.../cinecritique-frontend/flutter_app``)
2. Führe ``flutter run -d chrome --web-port=54841`` aus, wähle Gerät aus (Chrome Desktop für Webapp) falls danach gefragt wird

## Versionslog

### Version 0.1.0 (Initial Release)
- **Datum:** 2024-10-19 – 2024-10-19
- **Autoren:** Semar Emmy
- **Änderungen:**
  - Erster Commit

### Version 0.2.0 (Flutter App Setup)
- **Datum:** 2024-11-19 – 2024-11-19
- **Autoren:** Schniepp Julian
- **Änderungen:**
  - Flutter App Directory hinzugefügt
  - Leere Flutter App Generiert

### Version 0.3.0 (Dezember-Update)
- **Datum:** 2024-12-02 – 2024-12-31
- **Autoren:** Schniepp Julian, Krabel Lian
- **Änderungen:**
  - **UI-Struktur & Komponenten:**  
    - Aufteilung der Benutzeroberfläche in separate Dateien und Controller (Screens, UI-Logik)  
    - Hinzufügen von zusätzlichen Klassen, Abhängigkeiten und einem User Model  
  - **Dokumentation & Clean-Up:**  
    - Aktualisierung und Erweiterung der Readme sowie Einführung gemeinsamer ToDo-Dateien  
    - Bereinigung von Imports und allgemeine Code-Aufräumarbeiten  
  - **Prototyp-Implementierungen:**  
    - Erste Implementierung von Prototyp-Widgets und experimentellen Screens  
  - **Suchleiste:**  
    - Implementierung einer Searchbar zur Verbesserung der Usability  
  - **Keycloak-Integration:**  
    - Hinzufügen von Keycloak-Abhängigkeiten und -Parametern  
    - Anpassungen im Auth Service zur Vorbereitung der Keycloak-Authentifizierung

### Version 0.4.0 (Januar-Update: Erweiterte Funktionalitäten und Optimierungen)
- **Datum:** 2025-01-09 – 2025-01-30
- **Autoren:** Schniepp Julian, Krabel Lian, Föll Jonas
- **Änderungen:**
  - **Authentication & Keycloak-Integration:**
    - Einführung und Implementierung des Auth-Services sowie erste Schritte zur Keycloak-Integration (z. B. Commit „implemented auth service, todo: fix keycloak parameters“, „keycloak changes“ und „commenting out code“).
    - Fehlerbehebungen bei der Keycloak-Server-URL und Anpassungen an der OpenID-Logik zur Behebung von CORS-Fehlern und 404-Problemen (Commits wie „fixed keycloak server url“ und „comments and fixes to openid logic“) 
  - **Benutzeroberfläche & Navigation:**
    - Einführung und Optimierung der Sidebar für nicht angemeldete Benutzer; die Sidebar wurde integriert, angepasst und so konfiguriert, dass sie konsistent auf verschiedenen Seiten dargestellt wird (z. B. „sidebar eingefügt“ und „updated sidebar“).
    - Überarbeitung des Custom App Bar, um Keycloak-bezogene Einschränkungen zu umgehen (Commit „changes to custom_app_bar“).
    - Verbesserungen an der Moviepage und Home-Seite, inklusive vorübergehender Implementierungen und finaler Anpassungen für eine konsistente Darstellung (z. B. „temporary home screen implementation“ und „fertige home (main) page“)
  - **Rating & Userprofile:**
    - Umfassende Änderungen im Rating-Bereich: Mehrere Commits optimierten den Rating Controller, die Rating Screen und das Rating Widget – inklusive Debugging, Anpassungen der Endpunkte und Implementierung strategischer Logging-Statements (Commits wie „changes to rating controller“, „updated rating controller with correct endpoint“ und „changes to rating screen“).
    - Implementierung und Verbesserung der Userprofile-Seite zur Steigerung der Benutzerfreundlichkeit (z. B. „implemented userprofile screen“ und „improved userprofile“).
  - **API & Funktionalität:**
    - Mehrfache Updates der API-Konfiguration, insbesondere Anpassungen des _baseUrl, um eine stabile Kommunikation mit dem Backend zu gewährleisten (z. B. „adjusting api _baseUrl AGAIN“, „updates _baseUrl“).
    - Erweiterungen im Bereich der Favorites: Implementierung einer Suchfunktion, Aktualisierungen im Favorite Controller und Optimierungen bei der JSON-Verarbeitung (z. B. „added search to favorites page“, „updated favorite controller, minor fixes for json parsing“).
  - **Empfehlungen, Logging & Code-Optimierungen:**
    - Verbesserungen bei der Implementierung der Recommendations: Hinzufügen von Methoden (wie z. B. „added getemail to auth service“, „changes to recommendations“) und strategische Debugging-Maßnahmen zur Optimierung der Empfehlungslogik.
    - Diverse Code-Cleanups, Anpassungen in der Dokumentation (Readme- und Meta-Tag-Updates) sowie weitere kleinere UI- und Designanpassungen (z. B. „readme changes“, „updated meta tags“) 

### Version 0.5.0 (UI- & Responsiveness-Optimierungen)
- **Datum:** 2025-02-17 – 2025-02-...
- **Autoren:** Krabel Lian, Schniepp Julian
- **Änderungen:**
  - **Branch-Merge:**  
    - Zusammenführung von Entwicklungszweigen in den Main-Branch (Merge branch 'frontend_dev' into 'main').
  - **Suchleiste:**  
    - Dauerhafte Sichtbarkeit der Suchleiste („searchbar bleibt imer offen“).  
    - Optimierungen für mobile Ansichten, z. B. scrollbar auf dem Handy („suchleiste versuch scrollbar am handy“).  
    - Mehrere Anpassungen und Testversuche, um das Verhalten der Suchleiste zu verbessern („suchleiste verändert“, „suchbar macht faxen mim schließen nachm herz“, „searchbar fix“).
  - **Typografie & Layout:**  
    - Anpassungen der Schriftgrößen und Titelpositionierung („schriftgröße mann“, „hoffentlich passt der titel jetzt“, „schriftgröße auf 30 erhöht“, „schriftgröße des titels geändert“).  
    - Feinjustierung von UI-Elementen wie Hovereffekten in der Sidebar („letzte sidebar anpassungen (hovereffekt)“).
  - **Responsive UI & Navigation:**  
    - Optimierung der Sidebar, Moviepage und Userprofile für bessere Responsiveness („userprofile responsive“, „main page responsive“, „moviepage anpassung“).  
    - Überarbeitung der Navigationselemente, inklusive Burger-Menü-Anpassungen (Abstände, Layoutanpassungen – siehe „abstände burger menu“, „anpassungen burger menu“, „burgermenu überall gleich“).
  - **Rating & Favoriten:**  
    - Zentrierung und Anpassung der Rating Widgets („rating widgets immer zentriert“) sowie Tests und Optimierungen an den Rating-Seiten („anpassungen rating“, „anpassungen rating page“, „rating test 3 :)“).  
    - Verbesserte Darstellung der Favoritenansicht mit responsiven Layouts und alphabetischer Sortierung („favorite screen responsive“, „favoritenpage responsive“, „alphabetische sotrierung der filme“).
  - **Diverse Optimierungen:**  
    - Weitere kleinere UI-Anpassungen und Bugfixes zur Verbesserung der Benutzererfahrung.
