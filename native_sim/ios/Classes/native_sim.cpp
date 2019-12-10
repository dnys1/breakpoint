// boost_test.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <boost/numeric/odeint.hpp>
#include <boost/array.hpp>
#include <iostream>
#include "native_sim.h"

using namespace std;
using namespace boost::numeric::odeint;

typedef boost::array< double, 8 > state_type;
typedef runge_kutta_dopri5< state_type > stepper_type;

class sim {
    sim_vals m_vals;
public:
    sim(parameters params) {
        double T_K = params.T_C + 273.15;
        
        double KHOCl  = pow(10,-(1.18e-4 * T_K * T_K - 7.86e-2 * T_K + 20.5));
        double KNH4   = pow(10,-(1.03e-4 * T_K * T_K - 9.21e-2 * T_K + 27.6));
        double KH2CO3 = pow(10,-(1.48e-4 * T_K * T_K - 9.39e-2 * T_K + 21.2));
        double KHCO3  = pow(10,-(1.19e-4 * T_K * T_K - 7.99e-2 * T_K + 23.6));
        double KW     = pow(10,-(1.5e-4 * T_K * T_K - 1.23e-1 * T_K + 37.3));

        sim_vals vals;
        
        double H = pow(10, -params.pH);
        double OH = KW / H;
        
        vals.alpha0TotCl = 1/(1 + KHOCl/H);
        vals.alpha1TotCl = 1/(1 + H/KHOCl);

        vals.alpha0TotNH = 1/(1 + KNH4/H);
        vals.alpha1TotNH = 1/(1 + H/KNH4);

        vals.alpha0TotCO = 1/(1 + KH2CO3/H + KH2CO3*KHCO3/pow(H,2));
        vals.alpha1TotCO = 1/(1 + H/KH2CO3 + KHCO3/H);
        vals.alpha2TotCO = 1/(1 + H/KHCO3 + H*H/(KH2CO3*KHCO3));
        
        double TotCO = (params.Alk/50000 + H - OH)/(vals.alpha1TotCO + 2 * vals.alpha2TotCO);
        double H2CO3 = vals.alpha0TotCO*TotCO;
        double HCO3 = vals.alpha1TotCO*TotCO;
        double CO3 = vals.alpha2TotCO*TotCO;

        vals.k1 = 6.6e8 * exp(-1510/T_K);
        vals.k2 = 1.38e8 * exp(-8800/T_K);
        vals.k3 = 3.0e5 * exp(-2010/T_K);
        vals.k4 = 6.5e-7;
        vals.k5H = 1.05e7 * exp(-2169/T_K);
        vals.k5HCO3 = 4.2e31 * exp(-22144/T_K);
        vals.k5H2CO3 = 8.19e6 * exp(-4026/T_K);
        vals.k5 = vals.k5H*H + vals.k5HCO3*HCO3 + vals.k5H2CO3*H2CO3;
        vals.k6 = 6.0e4;
        vals.k7 = 1.1e2;
        vals.k8 = 2.8e4;
        vals.k9 = 8.3e3;
        vals.k10 = 1.5e-2;
        vals.k11p = 3.28e9*OH + 6.0e6*CO3;
        vals.k11OCl = 9e4;
        vals.k12 = 5.56e10;
        vals.k13 = 1.39e9;
        vals.k14 = 2.31e2;
        vals.kDOC1 = 5.4;
        vals.kDOC2 = 180;
        
        vals.H = H;
        vals.OH = OH;
        
        m_vals = vals;
    }
    
    void operator() (const state_type &x, state_type &dxdt, const double /* t */) {
        dxdt[0] = (-m_vals.k1*m_vals.alpha0TotCl*x[1]*m_vals.alpha1TotNH*x[0] + m_vals.k2*x[2] + m_vals.k5*x[2]*x[2] - m_vals.k6*x[3]*m_vals.alpha1TotNH*x[0]*m_vals.H + m_vals.kDOC1*x[2]*x[6]);
        dxdt[1] = (-m_vals.k1*m_vals.alpha0TotCl*x[1]*m_vals.alpha1TotNH*x[0] + m_vals.k2*x[2] - m_vals.k3*m_vals.alpha0TotCl*x[1]*x[2] + m_vals.k4*x[3] + m_vals.k8*x[5]*x[3] -
        (m_vals.k11p + m_vals.k11OCl*m_vals.alpha1TotCl*x[1])*m_vals.alpha0TotCl*x[1]*x[3] + 2*m_vals.k12*x[3]*x[4]*m_vals.OH + m_vals.k13*x[2]*x[4]*m_vals.OH -
                   2*m_vals.k14*x[3]*m_vals.alpha1TotCl*x[1] - m_vals.kDOC2*m_vals.alpha0TotCl*x[1]*x[7]);
        dxdt[2] = (m_vals.k1*m_vals.alpha0TotCl*x[1]*m_vals.alpha1TotNH*x[0] - m_vals.k2*x[2] - m_vals.k3*m_vals.alpha0TotCl*x[1]*x[2] + m_vals.k4*x[3] - 2*m_vals.k5*x[2]*x[2] +
                   2*m_vals.k6*x[3]*m_vals.alpha1TotNH*x[0]*m_vals.H - m_vals.k9*x[5]*x[2] - m_vals.k10*x[2]*x[3] - m_vals.k13*x[2]*x[4]*m_vals.OH - m_vals.kDOC1*x[2]*x[6]);
        dxdt[3] = (m_vals.k3*m_vals.alpha0TotCl*x[1]*x[2] - m_vals.k4*x[3] + m_vals.k5*x[2]*x[2] - m_vals.k6*x[3]*m_vals.alpha1TotNH*x[0]*m_vals.H - m_vals.k7*x[3]*m_vals.OH - m_vals.k8*x[5]*x[3] -
        m_vals.k10*x[2]*x[3] - (m_vals.k11p + m_vals.k11OCl*m_vals.alpha1TotCl*x[1])*m_vals.alpha0TotCl*x[1]*x[3] - m_vals.k12*x[3]*x[4]*m_vals.OH -
                   m_vals.k14*x[3]*m_vals.alpha1TotCl*x[1]);
        dxdt[4] = ((m_vals.k11p + m_vals.k11OCl*m_vals.alpha1TotCl*x[1])*m_vals.alpha0TotCl*x[1]*x[3] - m_vals.k12*x[3]*x[4]*m_vals.OH - m_vals.k13*x[2]*x[4]*m_vals.OH);
        dxdt[5] = (m_vals.k7*x[3]*m_vals.OH - m_vals.k8*x[5]*x[3] - m_vals.k9*x[5]*x[2]);
        dxdt[6] = (-m_vals.kDOC1*x[2]*x[6]);
        dxdt[7] = (-m_vals.kDOC2*m_vals.alpha0TotCl*x[1]*x[7]);
    }
};

struct record_vals {
    vector<y_vals>& m_states;
    vector<double>& m_times;
    string& m_csv;
    
    record_vals(vector<y_vals> &states, vector<double> &times, string &csv ) : m_states(states), m_times(times), m_csv(csv) {}
    
    void operator() (const state_type &x, double t) {
        y_vals new_y;
        new_y.TotNH = x[0];
        new_y.TotCl = x[1];
        new_y.NH2Cl = x[2];
        new_y.NHCl2 = x[3];
        new_y.NCl3  = x[4];
        new_y.I     = x[5];
        new_y.DOC1  = x[6];
        new_y.DOC2  = x[7];
        
        m_states.push_back(new_y);
        m_times.push_back(t);
        
        // Use \r\n for return to be compliant with rfc4810 which is required for Flutter csv package
        string newline = to_string(t) + "," + to_string(x[0]) + "," + to_string(x[1]) + "," + to_string(x[2]) + "," + to_string(x[3]) + "," + to_string(x[4]) + "\r\n";
        m_csv += newline;
    }
};

extern "C" __attribute__((visibility("default"))) __attribute__((used))
char* simulate
(
    double pH,
    double T_C,
    double Alk,
    double TotNH_ini,
    double TotCl_ini,
    double Mono_ini,
    double Di_ini,
    double DOC1_ini,
    double DOC2_ini,
    double tf
)
{
    parameters params;
    params.pH = pH;
    params.T_C = T_C;
    params.Alk = Alk;

#if DEBUG
    cout << "Parameters Received:" << endl;
    cout << "pH: " << pH << endl << "T_C: " << T_C << endl << "Alk: " << Alk << endl << "TotNH: " << TotNH_ini << endl << "TotCl: " << TotCl_ini << endl << "Mono: " << Mono_ini << endl << "Di: " << Di_ini << endl << "DOC1: " << DOC1_ini << endl << "DOC2: " << DOC2_ini << endl << "tf: " << tf << endl;
#endif
    
    y_vals y0;
    y0.TotNH = TotNH_ini;
    y0.TotCl = TotCl_ini;
    y0.NH2Cl = Mono_ini;
    y0.NHCl2 = Di_ini;
    y0.NCl3  = 0;
    y0.I     = 0;
    y0.DOC1  = DOC1_ini;
    y0.DOC2  = DOC2_ini;
    
    sim simulation(params);
    
    state_type x0 = { y0.TotNH, y0.TotCl, y0.NH2Cl, y0.NHCl2, y0.NCl3, y0.I, y0.DOC1, y0.DOC2 };
    vector<y_vals> y;
    vector<double> t;
    string csv = "";
    size_t steps = integrate_adaptive(make_controlled(1e-12, 1e-12, stepper_type()),
                                      simulation, x0, 0.0, tf, 0.1, record_vals(y, t, csv));
    
#if DEBUG
    cout << "Number of steps: " << steps << endl;
#endif
    char* cstr = new char[csv.length() + 1];
    strcpy(cstr, csv.c_str());
    
    return cstr;
}

