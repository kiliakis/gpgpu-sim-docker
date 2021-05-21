docker create --privileged --cpus 40 --rm \
	-v "$(pwd)/results:/home/kiliakis/simulations-gpgpu/util/job_launching/results" \
    --hostname docker \
	--name gpgpusim-vm-1.0 kiliakis/gpgpusim-vm:1.0
