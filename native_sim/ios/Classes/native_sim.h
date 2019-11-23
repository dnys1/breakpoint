//
//  main.h
//  boost
//
//  Created by Dillon Nys on 11/20/19.
//  Copyright © 2019 Dillon Nys. All rights reserved.
//

#ifndef native_sim
#define native_sim

struct sim_vals {
    double k1;
    double k2;
    double k3;
    double k4;
    double k5;
    double k5H;
    double k5HCO3;
    double k5H2CO3;
    double k6;
    double k7;
    double k8;
    double k9;
    double k10;
    double k11p;
    double k11OCl;
    double k12;
    double k13;
    double k14;
    double kDOC1;
    double kDOC2;
    
    double alpha0TotCl, alpha1TotCl;
    double alpha0TotNH, alpha1TotNH;
    double alpha0TotCO, alpha1TotCO, alpha2TotCO;
    
    double H, OH;
};

struct y_vals {
    double TotNH;
    double TotCl;
    double NH2Cl;
    double NHCl2;
    double NCl3;
    double I;
    double DOC1;
    double DOC2;
};

struct parameters {
    double pH;
    double T_C;
    double Alk;
};

#endif /* main_h */
