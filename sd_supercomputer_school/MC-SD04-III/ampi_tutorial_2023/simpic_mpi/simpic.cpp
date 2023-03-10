#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <stdarg.h>


#include "global.h"
#include <mpi.h>
#include "timing.cpp"
#include "diagnostics.cpp"
#include "trimatrix.cpp"
#include "fields.cpp"


inline void lhs(int j)
{
  lhsbuf[nlp] = pdata[j];
  lhsbuf[nlp+1] = pdata[j+1];
  nlp += 2;

#ifdef DEBUG
  fprintf(stderr, "rank %d nlp => %d\n", rank, nlp);
#endif 

}

inline void rhs(int j)
{
  rhsbuf[nrp] = pdata[j];
  rhsbuf[nrp+1] = pdata[j+1];
  nrp += 2;

#ifdef DEBUG
  fprintf(stderr, "rank %d nrp => %d\n", rank, nrp);
#endif 
}

inline Scalar gridx(Scalar x)
{
  return ((x - xl)/dx);
}

inline Scalar getfrac(Scalar x)
{
  static int n;

  n = int(x);
  return x-n;
}

inline void weightparticle(Scalar x, Scalar weight, Scalar *array)
{
  static int n;
  static Scalar frac, xx;
  
  xx = gridx(x);
  n = int(xx);
  frac = xx-n;

  array[n] += weight*(1. - frac);
  array[n+1] += weight*frac;
}

inline Scalar particleweight(Scalar x, Scalar *array)
{
  int n;
  static Scalar frac, xx;

  xx = gridx(x);
  n = int(xx);
  frac = xx-n;

  //fprintf(stderr,"******************************************************************AMPI rank [%d]: frac: %f array[n]: %f and array[n+1]: %f \n",rank,frac,array[n],array[n+1]);
  return frac*array[n+1] + (1.0 - frac)*array[n];
}

void moveparticles(Scalar dt)
{
  int i, j;
  Scalar E, x, v;

  starttime(PARTICLES);
  for(i=0, j=0; i < npart; )
    {
      
      /*#ifdef DEBUG
            fprintf(stderr, "PREVIOUS particle %d (%d): E=%g, x=%g, v=%g, qm=%g\n", i, j,
      	      E, pdata[j], pdata[j+1], qm);
      #endif*/
      
      
      E = particleweight(pdata[j], Earray);
      pdata[j+1] += qm*E;
      pdata[j] += pdata[j+1]*dt;

      /*#ifdef DEBUG
            fprintf(stderr, "AFTER particle %d (%d): E=%g, x=%g, v=%g, qm=%g\n", i, j,
      	      E, pdata[j], pdata[j+1], qm);
      #endif*/

      if((pdata[j] > xl) && (pdata[j] < xr))
	{
	  weightparticle(pdata[j], qscale, narray);
	  j += 2;
	  i++;
	}
      else
	{
	  /*#ifdef DEBUG
	   fprintf(stderr, "\nParticle %d[of %d] lost, E=%g\n", i, npart, E);
	  #endif*/ 

	  if(pdata[j] < xl)
	    {
	      lhs(j);
	    }
	  else
	    {
	      rhs(j);
	    }	  
	  npart--;
	  pdata[j] = pdata[2*npart];
	  pdata[j+1] = pdata[2*npart + 1];
	}
    }
  endtime(PARTICLES);
}

void communicateparticles(void)
{
  MPI_Request lstat, rstat;
  MPI_Request plstat, prstat;
  MPI_Request llstat, rrstat;
  MPI_Request pllstat, prrstat;
  MPI_Status stat;

#ifdef DEBUG
  fprintf(stderr, 
	  "Rank %d communicateparticles(), t=%g, nlp=%d, nrp=%d, npart=%d\n", 
	  rank, tt, nlp, nrp, npart);
  
#endif

  // recv/send from/to left
  if(rank != 0)
    {

#ifdef DEBUG
      fprintf(stderr, "left: Processor %d sending %d particles to proc %d\n",
	      rank, nlp, nl);
#endif

      MPI_Irecv(&nlr, 1, MPI_INT, nl, 0, MPI_COMM_WORLD, &lstat); 
      MPI_Isend(&nlp, 1, MPI_INT, nl, 0, MPI_COMM_WORLD, &llstat);
    }

  // recv/send from/to right
  if(rank != last)
    {

#ifdef DEBUG
      fprintf(stderr, "right: Processor %d sending %d particles to proc %d\n",
	      rank, nrp, nr);
#endif

      MPI_Irecv(&nrr, 1, MPI_INT, nr, 0, MPI_COMM_WORLD, &rstat);
      MPI_Isend(&nrp, 1, MPI_INT, nr, 0, MPI_COMM_WORLD, &rrstat);
    }
      
#ifdef DEBUG
  fprintf(stderr, "proc %d waiting for # of particles, t=%g\n", rank, tt);
#endif

  if(rank != 0)
    {
#ifdef DEBUG
      fprintf(stderr, "proc %d: rank != 0, t=%g\n", rank, tt);
#endif

      MPI_Wait(&lstat, &stat);  
#ifdef DEBUG
      fprintf(stderr, "left: Processor %d receiving %d particles from proc %d\n",
	      rank, nlr, nl);
#endif    
    }
  if(rank != last)
    {
#ifdef DEBUG
      fprintf(stderr, "proc %d: rank != last, t=%g\n", rank, tt);
#endif

      MPI_Wait(&rstat, &stat);
#ifdef DEBUG
      fprintf(stderr, "right: Processor %d receving %d particles from proc %d\n",
	      rank, nrr, nr);
#endif
    }
  
#ifdef DEBUG
  fprintf(stderr, "Rank %d ready for particle communication, t=%g:\n", rank, tt);
#endif


  // here, one would reallocate, if necessary
  // for this simple test, we use unrealistically
  // large buffers to avoid this possibility

  if(rank != 0)
    {
      // receive from left
      MPI_Irecv(&(pdata[2*npart]), nlr, MPI_SCALAR, nl, 0, MPI_COMM_WORLD, &plstat);

      npart += (nlr/2);

      // send to left
      MPI_Isend(lhsbuf, nlp, MPI_SCALAR, nl, 0, MPI_COMM_WORLD, &pllstat);

      //      if(rank != last)
      //	{
      //      MPI_Wait(&plstat, &stat);
	  //	}
    }
  if(rank != last)
    {
      MPI_Irecv(&(pdata[2*npart]), nrr, MPI_SCALAR, nr, 0, MPI_COMM_WORLD, &prstat);
      npart += (nrr/2);

      // send to right
      MPI_Isend(rhsbuf, nrp, MPI_SCALAR, nr, 0, MPI_COMM_WORLD, &prrstat);

      MPI_Wait(&prstat, &stat);
    }
  //  if(rank != 0) { MPI_Wait(&plstat, &stat); }

  #ifdef DEBUG
  fprintf(stderr, "rank %d waiting for MPI_Barrier(), t=%g\n", rank, tt);
  #endif

  // wait for all processors to catch up
  MPI_Barrier(MPI_COMM_WORLD);

  #ifdef DEBUG
  fprintf(stderr, "rank %d done with communicateparticles(), t=%g.\n", rank, tt);
  #endif

}

void print_diagnostics(char *fmod, int close=0)
{
  static int init = 0;
  char ffname[STR_SIZE];
  char temp[STR_SIZE];

  if(!init)
    {
      #ifdef DEBUG
      //      fprintf(stderr, "\nInitializing diagnostics...\n");
      #endif

      sprintf(diags[NDENSITY], "density");
      thediags[NDENSITY] = narray;
      sprintf(diags[NEFIELD], "E");
      thediags[NEFIELD] = Earray;
      sprintf(diags[NVOLTAGE], "phi");
      thediags[NVOLTAGE] = phiarray;
      sprintf(diags[NVXPHASE], "vxx");
      thediags[NVXPHASE] = pdata;

      for(int i=0; i < NDIAGNOSTICS; i++)
	{
	  sprintf(temp, "%s%s", diags[i], procname);
	  strcpy(diags[i], temp);
	}

      init = 1;
    }
  
  if(close)
    {
      return;
    }

  for(int i=0; i < NDIAGNOSTICS; i++)
    {
      sprintf(ffname, "%s%s%s", diags[i], fmod, fext);
      if(i < NVXPHASE)
	{
	  printtarray(i, ng, dx);
	}
      else
	{
	  printphase(ffname);	  
	}
    }
  printt();
}

void mainloop(Scalar tmax, Scalar dt)
{
  tt = 0.;
  while(tt < tmax)
    {
      #ifdef DEBUG
      fprintf(stderr, "rank %d mainloop: t=%g, npart=%d{\n", 
	      rank, tt, npart);
      #endif

      // reset needed variables
      nlp = nrp = 0;
      memcpy(narray, nback, ng*sizeof(Scalar));

      nparttot += npart;

      moveparticles(dt);
      
      #ifdef DEBUG
      //      fprintf(stderr, "after move particles, npart=%d\n", npart);
      #endif

      if(nproc > 1)
	{
	  starttime(MPITIME);
	  communicateparticles();
	  endtime(MPITIME);
	}
      

      advancefields(dt);

      #ifdef DEBUG
      //      fprintf(stderr, "after fields, npart=%d\n", npart);
      #endif

      if(diagnosticsflag)
	{
	  char msg[] = "";
	  starttime(DIAGNOSTICS);
	  print_diagnostics(msg);
	  endtime(DIAGNOSTICS);
	}

      #ifdef DEBUG
      //      fprintf(stderr, "after diagnostics, npart=%d\n", npart);
      #endif

      tt += dt;

      MPI_Barrier(MPI_COMM_WORLD);

      #ifdef DEBUG
      fprintf(stderr, "}[%d]\n", rank);
      #endif
    }
}

void allocate_particles(void)
{
  int j;

  // nproc + 1 -- safety factor for this test
  // (should be more dynamic)
  pdata = new Scalar[(nproc+1)*2*npart*sizeof(Scalar)];
  lhsbuf = new Scalar[(nproc+1)*2*npart*sizeof(Scalar)];
  rhsbuf = new Scalar[(nproc+1)*2*npart*sizeof(Scalar)];

  for(int i=0, j=0; i < npart; i++, j+=2)
    {
      pdata[j] = xl + ((i + 1)*(xr-xl))/Scalar(npart + 1);
      pdata[j+1] = 0.;
    }
}

void free_particles(void)
{
  delete [] pdata;
  delete [] lhsbuf;
  delete [] rhsbuf;
}

void init(void)
{

  // remove old .dat files
  system("rm -f *.dat");

  // get MPI data
  MPI_Get_version(&ver, &subver);  
  MPI_Comm_size (MPI_COMM_WORLD, &nproc);
  MPI_Comm_rank (MPI_COMM_WORLD, &rank);
  wtres = MPI_Wtick();

  // print processor string name
  sprintf(procname, "%03d", rank);

  // reset timer variables
  for(int j=0; j < NTIMES; j++)
    {
      tttimes[j] = 0.;
    }
  // label timer counters -- do this here because
  // I can't find any documentation on how to declare 
  // multidimensional variables at compile time
  // aka C is stupid
  sprintf(names[PARTICLES], "Particles");
  sprintf(names[FIELDS], "Fields");
  sprintf(names[MPITIME], "MPI");
  sprintf(names[DIAGNOSTICS], "Diagnostics");
  sprintf(names[INIT], "Initialization"); 

  nparttot = 0.;

  //  ntimesteps = 4; // now obtained from command line
  density = 1.E13;
  //  np2c = 1E7; // now obtained from command line
  epsilon = 8.85E-12;
  area = 1.;
  L = 1.;
  q = 1.602E-19;
  m = 9.1E-31;
  //  ng = NG; // now obtained from command line
  //  nc = ng - 1; // now obtained from command line

  xl = rank/Scalar(nproc);
  xr = (rank + 1.)/Scalar(nproc);
  xl *= L;
  xr *= L;
  
  Ll = xr - xl;
  dx = Ll / Scalar(nc);

  nl = rank - 1;
  nr = rank + 1;
  last = nproc - 1;
  if(rank == 0)
    {
      nl = last;
    }
  if(rank == last)
    {
      nr = 0;
    }

  //  npart = int(density*area*Ll/np2c);
  np2c = density*area*Ll/Scalar(npart);

  allocate_particles();
  init_fields();

  // calculate time step from plasma frequency
  wp = density*q*q/(epsilon*m);
  wp = sqrt(wp);

  dt = dtfactor/wp;

  qscale = np2c/(area*dx);

  t = ntimesteps*dt;
  qm = q*dt/m;

  diagnosticsflag = true;
}

void printdata(void)
{
  printf("rank %d of %d processors\n", rank, nproc);
  fprintf(stdout, "MPI version: %d.%d, ", ver, subver);
  fprintf(stdout, "MPI_Wtime precision: %g\n", wtres);
  printf("t=%.3g, dt=%.3g, ntimesteps=%d, ", t, dt, ntimesteps);
  printf("density=%.3g, wp=%.3g, np2c=%.3g\n", density, wp, np2c);
  printf("%d particles, ng=%d, nc=%d, ", npart, ng, nc);
  printf("L=%g, Ll=%g, dx=%g, area=%g\n", L, Ll, dx, area);

  fflush(stdout);
}

// free fields arrays
void free_fields(void)
{
  allocate_arrays(1);
}

void parsecmdline(int argc, char **argv)
{
  int i;
  int nnppcc;   // number of particles per cell
  int nnccpppp; // number of cells per processor 
  int nnnttt;   // number of time steps

  double ddttff, lhsdefault;

  #ifdef DEBUG
    fprintf(stderr, "Program name: %s\n", argv[0]);
  #endif

  ddttff = lhsdefault = 0.;
  nnppcc = nnccpppp = nnnttt = 0;

  for(i=1; i < argc; i++)
    {
      #ifdef DEBUG
      //      fprintf(stderr, "arg %d : %s\n", i, argv[i]);
      #endif

      if(strcmp(argv[i], "-ppc") == 0)
	{
	  i++;
	  sscanf(argv[i], "%d", &nnppcc);
	}
      else if(strcmp(argv[i], "-ncpp") == 0)
	{
	  i++;
	  sscanf(argv[i], "%d", &nnccpppp);
	}
      else if(strcmp(argv[i], "-nt") == 0)
	{
	  i++;
	  sscanf(argv[i], "%d", &nnnttt);
	}
      else if(strcmp(argv[i], "-dtfactor") == 0)
	{
	  i++;
	  sscanf(argv[i], "%lf", &ddttff);
	}
      else if(strcmp(argv[i], "-lhsv") == 0)
	{
	  i++;
	  sscanf(argv[i], "%lf", &lhsdefault);
	}
      else // default case
	{
	  fprintf(stderr, "\nError:\n");
	  fprintf(stderr, "Unrecognized argument \"%s\"\n", argv[i]);
	  Quit();
	}
    }

  #ifdef DEBUG
    fprintf(stderr, "\ncmd line args parsed: ");
    fprintf(stderr, "%d particles/cell, %d cells/processor, %d timesteps\n",
     nnppcc, nnccpppp, nnnttt);
  #endif

  if((nnppcc < 1) || (nnccpppp < 1) || (nnnttt < 1))
    {
      fprintf(stderr, "\nError, input arguments must be entered!\n");
      Quit();
    }

  if(ddttff <= 0.)
    {
      fprintf(stderr, "\nError, dtfactor MUST BE positive!\n");
      Quit();
    }

  // set simulation variables from input data
  ntimesteps = nnnttt;
  nc = nnccpppp;
  ng = nc + 1;
  npart = nc*nnppcc;
  dtfactor = ddttff;
  lhsvoltage = lhsdefault;
}

void Quit(void)
{
  free_particles();
  free_fields();

  allocate_fieldbuffers(1);

  if(diagnosticsflag)
    {
      printt(1);
      printtarray(0, 0, 0., 1);
    }

  #ifdef DEBUG
  //  fprintf(stderr, "proc %d ready to finalize MPI\n", rank);
  #endif


  //exit(0);
  //MPI_Abort(MPI_COMM_WORLD, 0);

   MPI_Finalize();
   exit(0);
}



int main(int argc, char **argv)
{
  MPI_Init(&argc, &argv);

  tstart = MPI_Wtime();

  starttime(INIT);

  parsecmdline(argc, argv);

  init();
  
  #ifdef DEBUG
  if(rank == 0)
    {
      printdata();
    }
  #endif

  endtime(INIT);

  mainloop(t, dt);

  #ifdef DEBUG
  //  fprintf(stderr, "Proc %d done with mainloop\n", rank);
  #endif

  MPI_Barrier(MPI_COMM_WORLD);

  tend = MPI_Wtime();
  
  if(rank == 0)
    {
      printtimes(stdout);
    }

  #ifdef DEBUG
  //  fprintf(stderr, "Proc %d ready to Quit()\n", rank);
  #endif

  Quit();

#ifdef DEBUG
  //  fprintf(stderr, "Proc %d DONE!!!\n", rank);
#endif
  return 0;
}
