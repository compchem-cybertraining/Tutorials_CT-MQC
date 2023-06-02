# Tutorials_CT-MQC

## 1. Installation

Assume we are working in the common "G-CTMQC" folder

### 1.1. Pre-build the [QuantumModelLib](https://github.com/lauvergn/QuantumModelLib)

#### Get the source

    git clone https://github.com/lauvergn/QuantumModelLib.git

#### Load proper fortran compiler via either 

    module load gcc/11.2.0

   or
 
    conda activate libra

#### Go to the directory, build the code, return to the top directory:

    cd QuantumModelLib
    make
    cd ../

   
### 1.2. Build the  G-CTMQC code    

#### Get the [G-CTMQC source](https://gitlab.com/agostini.work/g-ctmqc)

    git clone https://gitlab.com/agostini.work/g-ctmqc.git


#### Copy the compiled QuantumModelLib library to the current source directory:

    cd g-ctmqc/src
    cp ../../QuantumModelLib/libQMLibFull_gfortran_opt1_omp1_lapack1.a  .

#### Modify the Makefile, so that one line would read:

    LDFLAG = -L. -lQMLibFull_gfortran_opt1_omp1_lapack1  ## -lpot

#### Compile and build

    make
    cd ../../

#### The executable is:

    g-ctmqc/src/main.x



## 2. Program output (based on the original README.md coming with the code, credit - G-CTMQC authors):

The program generates a series of output files that are saved in different directories, i.e. coeff and trajectories.
Therefore, in order not to obtain errors during the execution of the program, these directories have to be created.
In 1D_TEST and in 2D_TEST, a script run.sh is provided to automatically launch the calculations and create the output
directories coeff and trajectories.

After successful execution of the program, the directories coeff and trajectories will contain a certain number of
files n = N / M, with N the total number of time steps and M the number of time steps after which the output is written
during the dynamics. In each subdirectory, the files are labelled with an index increasing with time, from 0 to n. In
the current version of the code, up to 9999 files can be created.

Description of the output:

        coeff

Each file (named coeff.xxxx.dat) in this directory contains the coefficients of the expansion of the electronic wavefunction
in the used electronic basis as a function of the position of the corresponding trajectory. Each file is in the form:
*  the first N_dof columns are the positions of the trajectories for each of the N_dof nuclear degrees of freedom;
*  the following N_st x N_st columns  are the real parts of the electronic density matrix elements, with N_st the number of
electronic states considered;
* the following N_st x N_st columns are the imaginary parts of the electronic density matrix elements.

        trajectories

In surface-hopping-based calculations, each file (named RPE.xxxx.dat) in this directory contains the values of the phase-space variables and the value of the potential energy surface(s), namely:
*  the first N_dof columns are the positions of the trajectories for each of the N_dof nuclear degrees of freedom;
*  the following N_dof columns are the momenta of the trajectories for each of the N_dof nuclear degrees of freedom;
*  the following column is the potential energy along the active state at the position of the trajectory;
*  the following N_st columns are the N_st adiabatic potential energies at the position of the trajectory;
*  the following column is the gauge-invariant part of the time-dependent potential energy surface;

In Ehrenfest and CT-MQC calculations, each file (named RPE.xxxx.dat) in this directory contains the values of the phase-space variables and the value of the potential energy surface(s), namely:
*  the first N_dof columns are the positions of the trajectories for each of the N_dof nuclear degrees of freedom;
*  the following N_dof columns are the momenta of the trajectories for each of the N_dof nuclear degrees of freedom;
*  the following column is the gauge-invariant part of the time-dependent potential energy surface;
*  the following N_st columns are the N_st adiabatic potential energies at the position of the trajectory.
Each file (named occ_state.xxxx.dat) contains the list of force/active state along each trajectory.

Additionally, the files BO_population.dat and BO_coherences.dat are created, containing the population of the adiabatic
states and the indicator of coherence as functions of time (the first columns is the time in atomic units). In surface-hopping-based calculations, the columns from 2 to N_st+1 of the file BO_population.dat contain the quantum electronic populations, while the following N_st columns contain the classical electronic populations. In CT-MQC and in Ehrenfest calculations, the last N_st
columns only contain zeros.

## 3. Program input (based on the original README.md coming with the code, credit - G-CTMQC authors):

The format of the input file is the following:

    &SYSTEM
      TYP_CAL                = "XXXXX"    !*character* XXXXX = CTMQC (CT-MQC calculations),
                                                               EHREN (Ehrenfest calculations),
                                                               TSHFS (Fewest-switches surface hopping calculations)
      SPIN_DIA               = X          !*logical* X = T only for calculations with spin-orbit coupling
                                                     in the spin-diabatic basis, otherwise X = F
      NRG_CHECK              = X          !*logical* X = T to switch off the spin-orbit coupling when the
                                                     energy between states is larger than NRG_GAP
      NRG_GAP                = X          !*real* only for calculations with spin-orbit coupling in the
                                                  spin-diabatic basis
      MODEL_POTENTIAL        = "XXXXX"    !*character* XXXXX = definition of the model as it appears in
                                                               QuantumModelLib
      OPTION                 = X          !*integer* X = 1, 2, 3 only for Tully's models
      NEW_POTENTIAL          = X          !*logical* X = F to use QuantumModelLib
                                                     X = T for NaI, IBr, double-well
      N_DOF                  = X          !*integer* X = number of nuclear degrees of freedom
      PERIODIC_VARIABLE      = X,X,X...   !*logical* one value for each nuclear degree of freedom
                                                     with X = T (periodic coordinate) or F
      PERIODICITY            = X,X,X...   !*real* one value for each nuclear degree of freedom
                                                  with X = the period in units of PI
      NSTATES                = X          !*integer* X = number of electronic states
      TYPE_DECO              = "XX"       !*character* XX = ED for energy decoherence corrections
                                                       XX = CT for coupled-trajectory corrections
      C_PARAMETER            = X          !*real* energy parameter for the energy decoherence correction
                                                  in surface hopping
      JUMP_SEED              = X          !*integer* seed for random number generator for the hopping
                                                     algorithm in SH calculation
      INITIAL_CONDITION_SEED = X      !*integer* seed for random number generator for the initial
                                                 conditions
    /
    
    &DYNAMICS
      FINAL_TIME       = X            !*real* X = length of the simulation in atomic units
      DT               = X            !*real* X = integration time step in atomic units
      DUMP             = X            !*integer* X = number of time steps after which the output is
                                                     written
      INIT_BOSTATE     = X            !*integer* X = initial electronic state
      NTRAJ            = X            !*integer* X = number of classical trajectories
      R_INIT           = X,X,X...     !*real* one value for each nuclear degree of freedom with
                                              X = average position of the initial nuclear distribution
      K_INIT           = X,X,X...     !*real* one value for each nuclear degree of freedom with
                                              X = average momentum of the initial nuclear distribution
      SIGMAR_INIT      = X,X,X...     !*real* one value for each nuclear degree of freedom with
                                              X = variance in position space of the initial nuclear
                                              distribution
      SIGMAP_INIT      = X,X,X...     !*real* one value for each nuclear degree of freedom with
                                              X = variance in momentum space of the initial nuclear
                                              distribution
      MASS_INPUT       = X,X,X...     !*real* one value for each nuclear degree of freedom with
                                              X = the nuclear mass
    /
    
    &EXTERNAL_FILES
      POSITIONS_FILE     = "XXXXX"    !*character* XXXXX = file containing the list of initial
                                                           positions for the trajectories;
                                                           if the field is empty, positions are
                                                           sampled according to R_INIT and SIGMAR_INIT
      MOMENTA_FILE       = "XXXXX"    !*character* XXXXX = file containing the list of initial
                                                           momenta for the trajectories;
                                                           if the field is empty, momenta are
                                                           sampled according to K_INIT and SIGMAP_INIT
      OUTPUT_FOLDER      = "XXXXX"    !*character* XXXXX = path to the location where the output is
                                                           written
    /
    
    


## 4. Additional resources:
 
 - Videos and slides for CT-MQC hands-on instruction can be found
in [this link](https://compchem-cybertraining.github.io/Cyber_Training_Workshop_2022/_episodes/10-ctmqc).

 - Articles about CT-MQC can be found
in [this link](https://web-s-ebscohost-com.gate.lib.buffalo.edu/ehost/pdfviewer/pdfviewer?vid=0&sid=74d471d8-ef66-47c0-a19c-886085e45773%40redis).

 - In UB-CCR, the only command needed to load is `module load gcc/11.2.0`
 and use `sbatch run.py` to submit the job.






