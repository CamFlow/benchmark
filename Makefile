prepare_lmbench:
	@echo "Preparing lmbench"
	mkdir -p build
	cd build && git clone https://github.com/dmonakhov/lmbench.git
	cd build/lmbench && git checkout eb0d55e8999d1275da480aff0fca98805e55916e

prepare_unixbench:
	@echo "Preparing unixbench"
	mkdir -p build
	cd build && git clone https://github.com/kdlucas/byte-unixbench.git
	cd build/byte-unixbench && git checkout aeed2ba662a9220089aee33be4123481dab0b524

prepare_pgbench:
	@echo "Preparing pgbench"
	pgbench -i -s 70 bench2

prepare_postmark:
	@echo "Preparing postmark"
	mkdir -p build/postmark
	cp -f src/postmark-1_5.c build/postmark/postmark-1_5.c
	cd build/postmark && cc -o postmark postmark-1_5.c
	@echo "Please ignore warning"

prepare:prepare_lmbench prepare_unixbench prepare_pgbench prepare_postmark

service_off:
	-sudo systemctl stop camflow-provenance.service

whole:
	camflow -e true
	camflow -a true

selective:
	camflow -e true
	camflow -a false

off:
	camflow -e false
	camflow -a false

run_lmbench: service_off
	@echo "Running lmbench..."
	mkdir -p results
	cd build/lmbench && make results
	cd build/lmbench && make rerun
	cd build/lmbench/results/ && make > ../../../results/lmbench.txt

run_unixbench: service_off
	@echo "Running unixbench..."
	mkdir -p results
	cd build/byte-unixbench/UnixBench && ./Run > ../../../results/unixbench.txt

run_pgbench: service_off
	@echo "Runninb pgbench"
	mkdir -p results
	./pgbench.sh > ./results/pgbench.txt

run_postmark: service_off
	@echo "set size 4096 102400"
	@echo "set subdirectories 10"
	@echo "set number 4500"
	@echo "set transactions 1500000"
	cd build/postmark && ./postmark

run_kernel: service_off
	 phoronix-test-suite benchmark pts/build-linux-kernel-1.7.0

run_R: service_off
	phoronix-test-suite benchmark pts/rbenchmark-1.0.2

run_unpack: service_off
	phoronix-test-suite benchmark pts/unpack-linux-1.0.0

run_apache: service_off
	phoronix-test-suite benchmark pts/apache-1.6.1

run: run_lmbench run_unixbench run_pgbench run_postmark run_kernel run_R run_unpack run_apache

clean:
	rm -rf build
	rm -rf results
