import 'package:breakpoint/models/models.dart';

class Defaults {
  /* SIMULTANEOUS ADDITION */
  static final double freeChlorineConc = 4.0;           // mg-Cl2/L
  static final double freeChlorineGasFeed = 100.0;      // lbs/d
  static final double freeChlorineLiquidFeed = 100.0;   // lbs/d
  static final double freeChlorineLiquidFeedConc = 50;  // %
  static final double chlorineToNitrogenRatio = 4;      // mg-Cl2 : mg-N
  static final double ammoniaGasFeed = 15.0;            // lbs/d
  static final double ammoniaLiquidFeed = 15.0;         // lbs/d
  static final double ammoniaLiquidFeedConc = 50.0;     // %
  static final double freeAmmoniaConc = 1.0;            // mg-N/L
  static final double plantFlowMGD = 2.0;               // MGD

  /* PREFORMED CHLORAMINES */
  static final double preformedMonochloramineConc = 4.0;// mg-Cl2/L
  static final double preformedDichloramineConc = 0.0;  // mg-Cl2/L
  static final double preformedAmmoniaConc = 0.1;       // mg-N/L

  /* BOOSTER CHLORAMINES */
  static final double boosterMonochloramineConc = 2.0;  // mg-Cl2/L
  static final double boosterDichloramineConc = 0.0;    // mg-Cl2/L
  static final double boosterAmmoniaConc = 0.5;         // mg-N/L
  static final double boosterAddedChlorineConc = 2.0;   // mg-Cl2/L

  static final double pH = 8.0;
  static final double alk = 150.0;                      // mg-CaCO3/L
  static final double tempC = 25.0;                     // degC
  static final double toc = 0.0;                        // mg-C/L
  static final double tocFast = 0.02;
  static final double tocSlow = 0.65;
  static final double simTime = 2;
  static final TimeUnit simTimeUnit = TimeUnit.hours;

  static final double breakpointFreeChlorineConc = 1.0;
  static final double breakpointFreeAmmoniaConc = 1.0;
}