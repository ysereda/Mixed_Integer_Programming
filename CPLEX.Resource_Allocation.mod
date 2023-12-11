/*********************************************
 * OPL 22.1.0.0 Model
 * Author: Yuriy Sereda
 * Creation Date: Dec 6, 2023 at 10:42:40 AM
 *********************************************/

// Time 9:30-11:00, 12:30-13:30 6 dec

// Parameters
int M = 3; // Number of machines.
int P = 4; // Number of personnel.
int T = 5; // Number of tasks.
float c[1..M] = [2.1, 3.0, 1.6]; // Cost of using each machine m per unit time.
float e[1..P] = [12.1, 13.0, 14.0, 11.6]; // Cost of employing each person p per unit time.
float o = 123.2; // Fixed overhead cost.
float u[1..M] = [222.1, 223.0, 1111.6]; // Usage limit (max time over the period) for each machine m.
float v[1..P] = [140.0, 141.1, 139.6, 142.9]; // Work hours limit (max time over the period) for each person p.
float l[1..T] = [4.02, 5.1, 3.6, 4.29, 6.08]; // Duration of each task t in hours. Assumed to be independent on machine m!
float d[1..T] = [124.02, 125.1, 123.6, 124.29, 126.08]; // Deadline of each task t in hours.
float r[1..T] = [123.02, 124.1, 122.6, 123.29, 125.08]; // Tardiness starts at these times for each task t.
float wc = 1.0; // weight of cost objective.
float wt = 1.0; // weight of tardiness objective.

// Decision variables
dvar float+ x[1..M]; // Time each machine m is used.
dvar float+ y[1..P]; // Time each person p is employed.
dvar boolean a[1..T, 1..M]; // Assignment of each task t to each machine m.
dvar boolean b[1..T, 1..P]; // Assignment of each task t to each person m.
dvar float+ f[1..T]; // Finish time for each task t.

// Objective 1: Minimize the total cost of quality control resource allocation.
// Objective 2: Minimize the total tardiness.
minimize wc * (sum(m in 1..M) (c[m]*x[m]) + sum(p in 1..P) (e[p]*y[p]) + o) + wt * sum(t in 1..T) (maxl(0, f[t] - r[t]));
// No throughput. Assuming all tasks must be completed!

subject to {
  // Each machine has a usage limit:
  forall(m in 1..M) {
    x[m] <= u[m];
  };
  
  // Each person has a work hours limit:
  forall(p in 1..P) {
    y[p] <= v[p];
  };
  
  // Each task is assigned to only one machine:
  forall(t in 1..T) {
    sum(m in 1..M) (a[t,m]) == 1;
  };
  
  // Each task is assigned to only one person:
  forall(t in 1..T) {
    sum(p in 1..P) (b[t,p]) == 1;
  };
  
  // Resource Workload. Match task duration with machine and personnel usage:
  forall(m in 1..M) {
    x[m] == sum(t in 1..T) (a[t,m]*l[t]);
  };
  forall(p in 1..P) {
    y[p] == sum(t in 1..T) (b[t,p]*l[t]);
  };
  
  // Finish time for each task t:
  forall(t in 1..T) {
    //Non-convex:
    //f[t] == sum(m in 1..M) ( a[t,m] * ( sum(t1 in 1..t) (a[t1,m]*l[t1]) ) ); // Assuming tasks are executed in ascending order of its number t on each machine!
    
    // Reformulate to make it linear in a:
    // Truth Table:
    // a[t,m]   a[t1,m]   x
    // 0        0         0
    // 0        1         0
    // 1        0         0
    // 1        1         1
    f[t] == sum(m in 1..M) sum(t1 in 1..t) ( maxl(0, a[t,m] + a[t1,m] - 1) * l[t1] );
  };
  
  // Due Date for each task t:
  forall(t in 1..T) {
    f[t] <= d[t];
  };

};
