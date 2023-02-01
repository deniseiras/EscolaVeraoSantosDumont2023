
### DIA 1
#### [SD01-I] - Intro ao SD - Roberto
- PArticão original
- cpu_dev
- nvidia_dev
 
Partições novas:
- sequana_cpu_dev
- sequana_gpu_dev
- 
Filas *shared -> filas pra pequenos testes
Srun -> apenas para executáveis
Sbatch -> batches ou arquivos executaveis
Sbatch –d afterany:<JOBID>   ....  dependencia

Softwares de avaliação de desempenho
- Scalasca
- HPCViewer

#### [SD01-II] Introdução E/S Paralela no SDUMONT

Lustre – Paralelo opensource  - André Ramos Carneiro 

Conteúdo do minicurso: 
[http://www.lncc.br/~andrerc/intro_ES_SD-2023.tar.gz](https://us02st1.zoom.us/web_client/bai5dum/html/externalLinkPage.html?ref=http://www.lncc.br/~andrerc/intro_ES_SD-2023.tar.gz)
http://www.lncc.br/~andrerc/intro_ES_SD-2023.zip
[https://www.lustre.org/](https://us02st1.zoom.us/web_client/bai5dum/html/externalLinkPage.html?ref=https://www.lustre.org/)
[https://wiki.lustre.org/Main_Page](https://us02st1.zoom.us/web_client/bai5dum/html/externalLinkPage.html?ref=https://wiki.lustre.org/Main_Page)
[http://www.cenapad-rj.lncc.br/tutoriais/materiais-hpc](https://us02st1.zoom.us/web_client/bai5dum/html/externalLinkPage.html?ref=http://www.cenapad-rj.lncc.br/tutoriais/materiais-hpc)
[http://www.cenapad-rj.lncc.br/tutoriais/materiais-hpc/semana-sdumont/](https://us02st1.zoom.us/web_client/bai5dum/html/externalLinkPage.html?ref=http://www.cenapad-rj.lncc.br/tutoriais/materiais-hpc/semana-sdumont/)
[http://www.cenapad-rj.lncc.br/cursos-e-seminarios/](https://us02st1.zoom.us/web_client/bai5dum/html/externalLinkPage.html?ref=http://www.cenapad-rj.lncc.br/cursos-e-seminarios/)

Ver comandos para o lustre como lfs find
Evitar ls –l  -> busca todos os Metadados
Evitar muitos arquivos em um diretorio
Evitar arquivos pequenos
Compilar no HOME -> Scratch
Aumente o stripe count para acesso paralelo ao mesmo arquivo

Darshan – peril das apps – Bruno Alves Fagundes
I_MPI_EXTRA_FILESYSTEM=on
I_MPI_EXTRA_FILESYSTEM_LIST=lustre
module load darshan/3.4.0_openmpi_gnu_4.1.4
export DARSHAN_LOGPATH=${SCRATCH}/darshan_logs

*gerando wrappers do darshan - não tem nos slides*

darshan-gen-cc.pl -- GCC
darshan-gen-cxx.pl -- INTEL
darshan-gen-cc.pl `which mpicc` --output mpicc.darshan
darshan-gen-cxx.pl `which mpicxx` --output mpicxx.darshan
Enviar job para slurm (continuar pelos slides)

MPIIO – ROMIO
Atividades de testes de performance ao sintonizar o tamanho do stripe no Lustre do SD.
Atividade 1 – lfs getstripe 
Atividade 2 a 4 – lfs setstripe
Realizadas as atividades e verificado o ganho de se usar o setstripe nos programas utilizados.

![Captura de tela de 2023-01-16 17-47-13](https://user-images.githubusercontent.com/6113640/212985195-94ef76b5-98fc-4eb6-ab9d-edbf1d828203.png)

[denis.ei_bt.C.36.mpi_io_full.ompi414+gnu_id10757886-30538_1-16-64705-1171699525086035457_1.darshan.pdf](https://github.com/monanadmin/monan/files/10438435/denis.ei_bt.C.36.mpi_io_full.ompi414%2Bgnu_id10757886-30538_1-16-64705-1171699525086035457_1.darshan.pdf)

[denis.ei_bt.C.36.mpi_io_full.ompi414+gnu_id10757900-9766_1-16-65641-17642690718324617382_1.darshan.pdf](https://github.com/monanadmin/monan/files/10438439/denis.ei_bt.C.36.mpi_io_full.ompi414%2Bgnu_id10757900-9766_1-16-65641-17642690718324617382_1.darshan.pdf)

### DIA 2
#### [SD02-I] - Introdução ao OpenMP – Matheus Serpa

pragma omp single –  somente a thread mais rápida (a primeira que chegar no código omp single) executa
ex 1 hello world ok
ex 2 ex Vector sum
Utilizar o omp parallel for com
``` 
#!/bin/bash
#SBATCH --nodes=1                      #Numero de Nós
#SBATCH --ntasks-per-node=1            #Numero de tarefas por Nó
#SBATCH --ntasks=1                     #Numero total de tarefas MPI
#SBATCH --cpus-per-task=48             #Numero de threads
#SBATCH -p sequana_cpu_dev             #Fila (partition) a ser utilizada
#SBATCH --time=5:00                    #Tempo do job
#SBATCH --exclusive
 
#Exibe os nós alocados para o Job
echo "Running on $SLURM_JOB_NODELIST"
 
cd $SLURM_SUBMIT_DIR
 
#Configura os compiladores
module load gcc/8.3
 
#Configura o executavel
EXEC="$SCRATCH/2-vsum.exec 50"
 
#configura o numero de threads, de acordo com o parametro definido no Slurm
#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK
export OMP_NUM_THREADS=$1
echo "executando com $OMP_NUM_THREADS Threads ..."
lscpu
 
srun -N 1 -c $1 $EXEC
```

src/2-vsum.c 
Usar o pragma omp atomic sempre que possível no lugar do critical (seção de texto)
```
long long int sum(int *v, long long int N){
long long int i = 0, sum = 0, sum_local;
 
        #pragma omp parallel private(i,sum_local)
{
sum_local = 0;
#pragma omp for
for(i = 0; i < N; i++)
sum_local += v[i];
}	
#pragma omp atomic
sum += sum_local;

return sum;
 
}
```

![Captura de tela de 2023-01-17 14-50-27](https://user-images.githubusercontent.com/6113640/212986594-b3ea0a59-5870-4225-862d-51916365701d.png)

![Captura de tela de 2023-01-17 15-52-21](https://user-images.githubusercontent.com/6113640/212986539-a5e157d8-8bf6-45ee-8ca7-4d94c950a58d.png)

Ex 3 – mostrado apenas.

#### Palestra O uso de FPGAs para computação de alto desempenho

![Captura de tela de 2023-01-17 13-33-46](https://user-images.githubusercontent.com/6113640/212985399-8a120ff3-fc76-4ea8-a707-83a9381baa99.png)

FPGAS ainda dependem muito de código de hardware proprietários.
OpenMP pode evoluir para tratar as FPGAS
OMPC – OpenMP Cluster Programming Model -  Desenvolvimento de frameworks baseado a eventos utilizados nas FPGAs

![Captura de tela de 2023-01-17 13-41-41](https://user-images.githubusercontent.com/6113640/212985627-0c7f1db1-bf64-4f75-8fea-7750efafb9b9.png)

#### MS_SD04-I - Programação com MPI
https://github.com/gpsilva2003/mpi
SD:
/scratch/padinpe/denis.eiras2/MC-SD04-I/mpi

module load openmpi/gnu/4.0.4
mkdir bin
make
mpirun -n 4 bin/mpi_simples
mpirun –obersubscribe -> + processos que cores

Estudo de caso - Integral trapézio
Revisão de funções MPI

### DIA 3
#### [SD02-II] -  Introdução à programação paralela e vetorial – Matheus Serpa
msserpa@inf.ufrgs.br
códigos alterados no SD:
scratch/padinpe/denis.eiras2/MC-SD02-II/

- Artigo que varia o número de threads durante a execução para encontrar a melhor configuração:  Aurora : seamless optimization of openMP applications

```
omp parallel for schedule(type, 3) reduction(+ : sum)
omp parallel for schedule(static, 3) reduction(+ : sum)
# t0 -> 0,1,2 , 6,7,8 …
# t1 -> 3,4,5 , 9,10,11

omp parallel for schedule(dynamic, 3) reduction(+ : sum)
# entrega qdo a thread está livre
# t0 -> 0,1,2 ,3,4,5 ,  9,10,11
# t1 -> 6,7,8 ,
# geralmente valores maiores que 1 para não afetar cache miss

omp parallel for schedule(guided, 10) reduction(+ : sum) 
# muda o número de chuncks conforme execução. Começa em valor alto e diminui até 10 pra ter um melhor balanceamento de carga. Tem O maior overhead de escalonamento
omp parallel for schedule(auto, 10) reduction(+ : sum) 
# auto decidido o que fazer
```

- Dica de livro: Designing and Building Parallel Programs: Concepts and Tools
for Parallel Software Engineering - Book by Ian Foster - https://www.mcs.anl.gov/~itf/dbpp/

- Dúvida: Quando se tem um processador com 2 sockets, digamos 12 cores por socket, ao usar 12 cores com OpenMP, ele pode distribuir em mais de um socket em algum caso, digamos, schedule(auto) ?
Pode usar OMP Affinity para setar: 
- https://gcc.gnu.org/onlinedocs/libgomp/GOMP_005fCPU_005fAFFINITY.html
- https://www.intel.com/content/www/us/en/develop/documentation/cpp-compiler-developer-guide-and-reference/top/optimization-and-programming/openmp-support/openmp-library-support/thread-affinity-interface.html

- Usar hwloc para mostrar a arquitetura: https://www.open-mpi.org/projects/hwloc/

**Programação vetorial**

Exercício 6-dot-product
pragma omp simd 
- tratar em laços mais internos para as instruções vetoriais (geralmente 512bits por instrução, e 2 instruções por core)
- deve ser usado o pragma senão não gera instruções avx512
- no caso do gcc, tem as diretivas:
```
-march=skylake-avx512
-mmmx
-msse
-msse2
-msse3
-mssse3
-msse4
-msse4a
-msse4.1
-msse4.2
-mavx
-mavx2
-mavx512f
-mavx512pf
-mavx512er
-mavx512cd
-mavx512vl
-mavx512bw
-mavx512dq
-mavx512ifma
-mavx512vbmi
```
Assembly:
```
objdump -d caminho_executavel > /tmp/avx.asm
grep "%zmm" /tmp/avx.asm
```
Forçar o SIMD no intel: qopt-zmm-usage=high
```
CFLAGS = -qopt-report=5 -no-vec -qopenmp -xHost -Wall -Wextra -qopt-zmm-usage=high

for i in `seq 1 3`; do OMP_NUM_THREADS=2 ./6-dot-product.exec 10; done
number of elements: 10 x 10E7
```
- Exercicio 7: Alterando o codigo de i,j,k para ikj melhora significativamente o codigo serial - de 83s para 16s. (ver nos slides a solução completa)

- Desafio - ex 8 - muito específico pra intel
- usar intrinsics da intel AVX ao inves do pragma omp simd

- Desafio - ex 9 - petroleo - tentar fazer a partir do serial

- slides completos e  soluções: 
https://www.inf.ufrgs.br/~msserpa/MC-SD02-I-II-sol.zip

#### [SD02-IV] Profiling e otimização em códigos C/C++

Flat Profile
Call Graph
**Gprof**
```
gcc -g -pg matmul.c
./a.out 1000
gprof a.out
```
**Valgrind** - maquina virtual - rel completo para verificar os cache misses
desvantagem -> lento
- memcheck
- cachegrind - simula uso de cache (hits e miss)
- callgrind - gera o grafo de chamadas (kcachegrid para visualização)
- gcc matmul.c -g
- valgrind –tool=cachegrind ./a.out 400
![Captura de tela de 2023-01-18 14-49-58.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/4843639a-851f-4d61-ae83-44528867a36a)

- static inline int -> função que é chamada como uma linha (não tem o overhead de colocar na pilha)
- #declare -> inline init

**godbold.org** -> verifica cod assembly gerado por tipo de compilador


### DIA 4
#### [SD05-I] Introdução a workflows científicos paralelos em Python/Parsl
d.carvalho@ieee.org
**Apresentação:** https://onedrive.live.com/?authkey=%21AKGyBjiQSGOkQdA&cid=FF204613F816AC63&id=FF204613F816AC63%21994119&parId=FF204613F816AC63%21994118&o=OneUp
**Programas:** https://github.com/diegomcarvalho/2021-ProgramaVeraoSD
Tese de Doutorado: Controle distribuído de Workflows em malhas computacionais. Diego Carvalho
Livro: O Quarto paradigma
baseado em análise e exploração de massas de dados
**Pode ser bastante útil para a automação de builds e testes do Monan**
O RAY também é bastante utilizado para e-Science

Requisitos de Experimentos Científicos:
![Captura de tela de 2023-01-19 08-33-15.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/996e27ea-2c96-4472-955f-be65bef1c06d)

Desideratum - um dos mais completos
Usado no Santos Dumont ?
Workflows podem ser:
- abstratos (qdo não se pode executar computação )
- concretos (dependem de recursos computacionais)

Tipos de workflows:
- Centralizado - um maestro
- Hierárquico - maestro distribui pra outros maestros
- Distribuído - vários maestros
Por ser: 
- Textual
- Gráfico: 
  - Taverna https://incubator.apache.org/projects/taverna.html
  - Orange
Padrões a serem reutilizados, como “fork” de uma tarefa, sequências, ou uma tarefa depende de outras (sincronização) , operadores condicionais …

![Captura de tela de 2023-01-19 09-18-38.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/f4575286-5dc4-4f3f-9ab2-de8d1ba21889)
Google Cloud, Azure (AWS?) tem ferramentas de workflow usados nas empresas

**Parsl**
https://1drv.ms/b/s!AmOsFvgTRiD_vNZHobIGOJBIY6RB0A?e=9SLHGq

Para o SD … ver slides 53 …
```
pip3 install parls
pip install jupyter
module add python/3.8.2
```
Pode-se criar blocos que podem disparar tarefas MPI no SD:

exemplos de parsl no SD github do Diego - BIOCOMP
exemplo de ray - mapmob no github do Diego

É possível salvar os metadados do workflow em SqlLite 

Hands on
```
git clone https://github.com/diegomcarvalho/2021-ProgramaVeraoSD
python3 -m venv parsl_env
source parsl_env/bin/activate
pip3 install parsl
cd 2021-ProgramaVeraoSD/00-Hello/
python3 00_hello_parsl.py
```
**Palestra Transforming Science and Engineering Research Through An Innovative High Performance AI+HPC Ecosystem at PSC**
![Captura de tela de 2023-01-19 13-03-53.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/a277f3e6-9811-43f5-a839-e98d56d20b5d)

![Captura de tela de 2023-01-19 13-05-30.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/febc32d5-b6d3-4420-9668-dc73fff5709b)

![Captura de tela de 2023-01-19 13-56-34.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/3ef685cf-3e43-4e1d-89cc-8573a691b3d3)

#### [SD04-III] AMPI - Adaptive MPI
Esteban Meneses

![Captura de tela de 2023-01-19 14-13-36.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/31863524-0f29-49fe-ab83-4c803279a338)
usa OpenMP, MPI, Python, R

Laboratório: https://gitlab.com/CNCA_CeNAT/ampi_tutorial_2023

![Captura de tela de 2023-01-19 14-50-49.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/0cfc1267-4d13-4e9b-bf3c-f2e212beb9b2)

Exercício em /mnt/beegfs/denis.eiras/MC-SD04-III/ampi_tutorial_2023/stencil
make no diretorio stencil - acertar o compilador 
Executar:
```
/charmrun ./stencil 4 4 2 10 +p4  ++local
```
![Captura de tela de 2023-01-19 16-36-40.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/5b5e1e38-5b74-4aca-ac21-7e8f0058a933)

Exercício “lulesh”
/mnt/beegfs/denis.eiras/MC-SD04-III/ampi_tutorial_2023/lulesh/skeleton
make no dir skeleton `make`
executar:
```
./charmrun ./lulesh_ampi +p8 +vp64 -s 20 -i 20 -c 50 -b 3 -p +balancer GreedyLB ++local
```
ver os TODO's a fazer
no diretorio solution tem a solução do mesmo programa skeleton modificado

Número de migrações no log abaixo. Deve ser reduzido devido ao overhead do framework: 
![Captura de tela de 2023-01-19 17-16-55.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/71f84bdb-d414-48d1-a7cd-778cc26aa70d)

### DIA 7
Introdução ao Cuda aware
murilo.boratto@fieb.org.br
https://github.com/muriloboratto/MC-SD03-II
Passo a passo:
- https://www.lncc.br/~andrerc/MC-SD03-II_sdumont.txt

Notas do chat:

> Atenção para quem está executando no sdumont: no passo do ncclAllGather, valtou inserir a célula que realiza a compilação. Para contornar, basta adicionar a linha "nvcc ncclAllGather.cu -o ncclAllGather -lnccl $CPPFLAGS $LDFLAGS" dentro do script de submissão
> ...antes de executar o código (linha "./ncclAllGather"). Isso deve ser feito editando a célula que inicia com a linha "%%writefile v100-ncclAllGather.sh"
> 
> Voltamos com NVSHMEM no algoritmo do cálculo de pi (Monte Carlo)
> Um detalhe: O NVSHMEM ainda não está funcionando corretamente no SDumont. Essa parte, notebook 7, não vai funcionar no SDumont.
> 

Anotações do Laboratório feito no SD:
- Tentou-se usar a fila nvidia_dev para os exercícios, mas deu erro por exemplo no ex. 4 - Pi = 0 (alloc -N 1 -n 1 -p nvidia_dev)
- não foi possível usar a fila sequana_gpu_dev
- usou-se o login sdumont18

Seguir os passos enviados aqui (passo 5) para instalação do ambiente do conda:
- https://www.lncc.br/~andrerc/MC-SD03-II_sdumont.txt

Utilizando o JupyterLab no SDumont::

> ApÃ³s ter se conectado no sdumont, entrar no nÃ³ de login sdumont18:
> 
> ssh sdumont18
> 
> 5.1) Carregar o mÃ³dulo do anaconda
> 
> 
> module load anaconda3/2020.11
> 
> 5.2) Criar um ambiente virtual (na Ã¡rea do SCRATCH)
> 
> 
> conda create --prefix $SCRATCH/conda-env/jupyter python=3.9
> 
> 5.3) Ativar o ambiente vritual
> 
> 
> source activate $SCRATCH/conda-env/jupyter
> 
> 
> 5.4) Instalar o jupyterlab (pode utilizar esse mesmo procedimento para instalar outras dependÃªncias)
> 
> 
> pip install jupyterlab
> 
> 5.5) Verificar o ip do nÃ³ de login:
> 
> 
> Os ips dos nÃ³s de login, que sÃ£o acessÃ­veis atravÃ©s da conexÃ£o da VPN, possuem o prefixo 146.134.143 e com a seguinte terminaÃ§Ã£o:
> 
> 
> 146.134.143.241 sdumont11
> 146.134.143.242 sdumont12
> 146.134.143.243 sdumont13
> 146.134.143.244 sdumont14
> 146.134.143.245 sdumont15
> 146.134.143.246 sdumont16
> 146.134.143.247 sdumont17
> 146.134.143.248 sdumont18
> 
> 
> EntÃ£o, ao executar o comando abaixo, verifique qual Ã© o ip do nÃ³ que vocáº½ estÃ¡ alocado.
> 
> ip address | grep 146.134.143
> 
> * Deve aparecer o ip do sdumont18 - 146.134.143.248 
> 
> 5.6) Iniciar o jupyter-lab
> 
> 
> jupyter-lab --port=8559  --ip=0.0.0.0 --no-browser
> 
> 
> 
> ... aÃ­ vai aparecer a url de acesso. Ex:
>  
> 
>   To access the notebook, open this file in a browser:
>       file:///scratch/PROJETO/USUARIO/.local/share/jupyter/runtime/nbserver-18677-open.html
>   Or copy and paste one of these URLs:
>       http://sdumont1X:8559/?token=4606c10359515c039ce45c88968fc752d80ba6abec791880
>    or http://127.0.0.1:8559/?token=4606c10359515c039ce45c88968fc752d80ba6abec791880
> 
> 
> 
> 5.7) Criar o tunel ssh para poder acessar o notebook a partir da mÃ¡quina local:
> 
> No seu computador, abra um novo terminal e crie o tÃºnel ssh.
> 
> Atente-se pois o tÃºnel Ã© criado apontando para o nÃ³ de login onde o jupyter estÃ¡ em execuÃ§Ã£o.
> 
> Os IPs referem-se ao IP de nÃ³ de login, observados no item 5.5
> 
> 
> $ ssh -L8559:146.134.143.248:8559 meu.login@146.134.143.248
> 
> 
> 5.8) Acessar o notebook utilizando a url disponibilizada pelo Jupyter, copiando no seu navegador:
> 
> Por exemplo, colei a url http://127.0.0.1:8559/?token=4606c10359515c039ce45c88968fc752d80ba6abec791880 no navegador da minha mÃ¡quina local.
> 

A criação do túnel funciona mas não deu para acessar o jupyter pelo browser local. O firefox foi iniciado dentro do nó sdumont18 e acessado via http://127.0.0.1:8559/lab?token=92cc6f9c6268e38b66a22f02bc905d3f46283ca1f3dd9994

- Instalação do env: /scratch/padinpe/denis.eiras2/conda-env/jupyter)

Exercícios em /scratch/padinpe/denis.eiras2/MC-SD03-II/MC-SD03-II/supercomputers/SDumont

O exercício monte_carlo_pi_cuda.cu gerou PI=0 ao usar a file nvidia_dev . Executando localmente funcionou.

**Palestra VI - Rui Carlos Oliveira**

EuroHPC Joint Undertaking
In this talk I will present the current Portuguese HPC infrastructure landscape in the context of the EuroHPC Joint Undertaking. Emphasis will be put on the new Deucalion supercomputer and on the efforts to make it one of the most power efficient facilities building an end-to-end, from the user to the grid, power management system.

![Captura de tela de 2023-01-24 13-10-45.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/dc95b260-7883-4be3-86d3-e605fe60e99b)

“Develop awareness, incentive and billing mechanisms for HPC usage and promote sustainable behaviors in users”

Sistema de gerenciamento de computação e energia

- Criação de uma função de custo local, baseada na configuração de energia utilizada, para prever as melhores configurações de economia de energia
- reagendar jobs para minimizar o custo
- Estimar consumo com jobs reagendados
- Re avaliar o consumo global

![Captura de tela de 2023-01-24 13-42-50.png](https://images.zenhubusercontent.com/6335d6f2d6d9bb4660047b43/29188e14-96fd-4bd1-ab5d-ce252b610982)

#### [SD07-I] Introdução a Deep Learning
pcruzesilva@nvidia.com
NGC - Nvidia GPU Cloud
- Containers, bibliotecas gratuitos otimizado para as GPU's
catalog.ngc.nvidia.com
- versões de containers na aba Tags
- ex: executado com TensorFlow mais antigo que no site:
  - docker pull nvcr.io/nvidia/tensorflow:21.07  … (falta params)
- docker run …
- exibido um exemplo de segmentação 
