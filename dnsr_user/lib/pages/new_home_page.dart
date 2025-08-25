import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/shared_bottom_nav_bar.dart';
import '../pages/new_report_incident_page.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';

class NewHomePage extends StatelessWidget {
  const NewHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color(0xFFD4A017);

    return Scaffold(
      backgroundColor: bgColor, // yellow background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.15,
                  padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                  child: Text(
                    AppLocalizations.of(context)!.hiWelcomeToDNSR,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // White rounded container covering everything below
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // Added bottom padding for navbar space
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9F8ED),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    // Intro text
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        AppLocalizations.of(context)!.chooseOption,
                        textDirection: TextDirection
                            .ltr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromARGB(176, 0, 0, 0),
                        ),
                      ),
                    ),

                    // Buttons
                    Expanded(
                      child: ListView(
                        children: [
                          // Report Incident button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              final userProfile = authProvider.userProfile;
                              final isProfileComplete = userProfile?.isProfileComplete ?? false;
                              final isRestricted = !isProfileComplete;

                              return GestureDetector(
                                onTap: isRestricted ? null : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const NewReportIncidentPage(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                                  margin: const EdgeInsets.only(bottom: 20),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        offset: const Offset(0, 2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Image(
                                        image: AssetImage("assets/images/alert.png"),
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!.reportIncident,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              AppLocalizations.of(context)!.reportIncidentSubtitle,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Lock icon for restricted users
                                      if (isRestricted)
                                        const Icon(
                                          Icons.lock,
                                          color: Colors.white70,
                                          size: 24,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Route Codes button
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(AppLocalizations.of(context)!.routeCodesComingSoon),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Image(
                                    image: AssetImage(
                                      "assets/images/route_code.png",
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.routeCodes,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.routeCodesSubtitle,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // Floating navigation bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: const SharedBottomNavBar(),
        ),
      ],
    ),
  ),
);
  }
}
