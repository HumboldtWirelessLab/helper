public class GeoParser {

  static double deg2rad(String deg) {
    return (Double.parseDouble(deg) * Math.PI / 180.0);
  }

  static double Vincenty_Distance(String lat1, String lon1, String lat2, String lon2, boolean us) {
    // http://www.movable-type.co.uk/scripts/LatLongVincenty.html
    if (Math.abs(Double.parseDouble(lat1)) > 90 || Math.abs(Double.parseDouble(lon1)) > 180
            || Math.abs(Double.parseDouble(lat2)) > 90 || Math.abs(Double.parseDouble(lon2)) > 180) {
      throw new IllegalArgumentException("Wrong arguments");
    }
    if (lat1.equals(lat2) && lon1.equals(lon2)) {
      return 0;
    }

    double lat1d = deg2rad(lat1);
    double lon1d = deg2rad(lon1);
    double lat2d = deg2rad(lat2);
    double lon2d = deg2rad(lon2);

    if ( (lat1d < 0.1) || (lon1d < 0.1 ) || (lat2d < 0.1) || (lon1d < 0.1) ) return 0.0;

    double a = 6378137, b = 6356752.3142, f = 1 / 298.257223563;
    double L = lon2d - lon1d;
    double U1 = Math.atan((1 - f) * Math.tan(lat1d));
    double U2 = Math.atan((1 - f) * Math.tan(lat2d));
    double sinU1 = Math.sin(U1), cosU1 = Math.cos(U1);
    double sinU2 = Math.sin(U2), cosU2 = Math.cos(U2);
    double lambda = L, lambdaP = 2 * Math.PI;
    double iterLimit = 20;
    double cosSqAlpha = 0.0, sinSigma = 0.0, cos2SigmaM = 0.0, cosSigma = 0.0, sigma = 0.0;
    while (Math.abs(lambda - lambdaP) > 1e-12 && --iterLimit > 0) {
      double sinLambda = Math.sin(lambda), cosLambda = Math.cos(lambda);
      sinSigma = Math.sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda) +
              (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) * (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
      cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
      sigma = Math.atan2(sinSigma, cosSigma);
      double alpha = Math.asin(cosU1 * cosU2 * sinLambda / sinSigma);
      cosSqAlpha = Math.cos(alpha) * Math.cos(alpha);
      cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;
      double C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
      lambdaP = lambda;
      lambda = L + (1 - C) * f * Math.sin(alpha) * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
    }
    if (iterLimit == 0) {
      throw new IllegalArgumentException("Formula failed to converge.");
    }  // formula failed to converge
    double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
    double A = 1 + uSq / 16384 * (4096 + uSq * (-768 + uSq * (320 - 175 * uSq)));
    double B = uSq / 1024 * (256 + uSq * (-128 + uSq * (74 - 47 * uSq)));
    double deltaSigma = B * sinSigma * (cos2SigmaM + B / 4 * (cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM) - B / 6 * cos2SigmaM * (-3 + 4 * sinSigma * sinSigma) * (-3 + 4 * cos2SigmaM * cos2SigmaM)));
    double s = b * A * (sigma - deltaSigma);

    if (us) {
      double dist = s / 1609.344;
      return (Math.round(5280 * 1 * dist) / 1);// + ' ft';
    } else {
      double dist = s / 1000;
      return (Math.round(1000 * dist) );// + ' m';
    }
  }

  public static void main(String[] args) {

    if (args.length != 4 &&  args.length != 6) throw new IllegalArgumentException("wrong number of arguments; required: lat1 lon1 lat2 lon2 [height1 height2]");

    String lat1 = args[0]; //"13.5291316666666000";
    String lon1 = args[1]; //"52.4303833333333000";
    String lat2 = args[2]; //"13.5310550000000000";
    String lon2 = args[3]; //"52.4296600000000000";

	double d = Vincenty_Distance(lat1, lon1, lat2, lon2, false);
	
	if (args.length == 6) {

		double h1 = Double.parseDouble(args[4]);
		double h2 = Double.parseDouble(args[5]);
		d = Math.sqrt( Math.pow(d,2) +  Math.pow(Math.abs(h1-h2),2) );// norm eines vektors im euklidischen raum
	}

    System.out.println(d);
  }
}
