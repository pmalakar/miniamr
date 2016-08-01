#!/bin/bash -x
#COBALT --disable_preboot
 
#export L1P_POLICY=std
#export BG_THREADLAYOUT=1   # 1 - default next core first; 2 - my core first

#Free bootable blocks
boot-block --reboot
 
NODES=$1
PROG=miniAMR.x.tau

for iter in 1 
do
 for ppn in 4 
 do
  #for size in 10 40 80 120 160 200 240 280
  for maxblockspe in 4000 
  do
	 for nx in 8  
    do
	  for ny in 8  
	  do	
	   for nz in 8  
	   do	
		echo 
		echo "* * * * *"
		echo 
		RANKS=`echo "$NODES*$ppn"|bc`
		#npx=`echo "${NODES}/4"|bc`
		if [ $RANKS -eq 128 ]; then
			npx=8
			npy=4
			npz=4
		elif [ $RANKS -eq 256 ]; then
			npx=8
			npy=8
			npz=4
		elif [ $RANKS -eq 512 ]; then	
			npx=8
			npy=8
			npz=8
		elif [ $RANKS -eq 1024 ]; then		
			npx=16
			npy=8
			npz=8
		elif [ $RANKS -eq 2048 ]; then		
			npx=16
			npy=16
			npz=8
		elif [ $RANKS -eq 4096 ]; then		
			npx=16
			npy=16
			npz=16
		elif [ $RANKS -eq 8192 ]; then		
			npx=32
			npy=16
			npz=16
		elif [ $RANKS -eq 16384 ]; then		
			npx=32
			npy=32
			npz=16
		elif [ $RANKS -eq 32768 ]; then		
			npx=32
			npy=32
			npz=32
		fi	

		#2 moving spheres
		ARGS="--num_refine 4 --max_blocks $maxblockspe --init_x 1 --init_y 1 --init_z 1 --npx $npx --npy $npy --npz $npz --nx $nx --ny $ny --nz $nz --num_objects 2 --object 2 0 -1.10 -1.10 -1.10 0.030 0.030 0.030 1.5 1.5 1.5 0.0 0.0 0.0 --object 2 0 0.5 0.5 1.76 0.0 0.0 -0.025 0.75 0.75 0.75 0.0 0.0 0.0 --num_tsteps 60 --stages_per_ts 16" 

		OUTPUT=${PROG}_${iter}_${maxblockspe}_N${NODES}_R${ppn}
		ENVS="PAMID_COLLECTIVES_MEMORY_OPTIMIZED=1"
		echo "Starting $PROB $iter $OUTPUT on $RANKS processes ($NODES nodes) with ARG=$ARGS"
		runjob --np $RANKS -p $ppn --block $COBALT_PARTNAME --verbose=INFO --envs ${ENVS} --envs TAU_TRACK_MESSAGE=1 --envs TAU_THROTTLE=0 --envs TAU_COMM_MATRIX=1 : ${PROG} ${ARGS} > $OUTPUT

		echo 
		echo "* * * * *"
		echo 
 	   done
 	  done
 	 done
  done
 done
done

exit

