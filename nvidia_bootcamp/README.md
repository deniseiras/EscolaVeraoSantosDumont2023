### DIA 8
#### LNCC AI for Science Bootcamp

1. Please join the Slack
https://join.slack.com/t/lnccaiforscie-ry54632/shared_invite/zt-1mpy9h8oh-nwnNHvl63QUGKiZvqiNfHg  channel today. All communications for the event will
be announced via this workspace.
**O slides estarão disponíveis no canal presentation.**

2. Learn how to access the cluster
https://drive.google.com/file/d/1lWwEMDYHOPsAypLZ7uu_2ipiHeb1Azql/view?usp=share_link
A cluster connection session is part of Day 1. If you have any
questions related to the cluster, please submit them during or after that
session in the event Slack #nvidia-cluster-support channel. We do not have
anyone available to support until the start of the event. You will receive
an email from Axis to activate your account by tomorrow. Please check your
spam folder.
Agenda (all times in BRT):
Day 1 - Wednesday, January 25, 2023: 09:00 AM - 12:00 PM
* 09:00 AM - 09:15 AM: Welcome (Moderator)
* 09:15 AM - 09:30 AM: Connecting to a cluster
* 09:30 AM - 10:00 AM: Introduction to GPU computing (Lecture)
* 10:00 AM - 11:00 AM: Introduction to AI (Lecture)
* 11:00 AM - 12:00 PM: CNN Primer and Keras 101 (Lecture and Lab)
Day 2 - Thursday, January 26, 2023: 09:00 AM - 12:30 PM
* 09:00 AM - 10:30 AM: Tropical cycle detection (Lab + Challenge)
* 10:30 AM - 10:45 AM: Break
* 10:45 AM - 12:15 PM: Steady Flow Estimation (Challenge)
* 12:15 PM - 12:30 PM: Wrap up and Q&A

Join Zoom Meeting
https://us06web.zoom.us/j/84651547357?pwd=enAyM25uZkE3NThwRUorazJFek9Xdz09

Conexão ao cluster: 
- Seguir procedimentos disponibilizados no ppt no slack. Lá foi disponibilizado https://drive.google.com/file/d/1lWwEMDYHOPsAypLZ7uu_2ipiHeb1Azql/view
Os passos:
- entrar na plataforma axis com usuário e senha fornecidos via email (meu login no axis: g5s5anct)
- pegar o hashcode para conexão com ssh
- fazer o ssh ou entrar na aba que abre o terminal
- executar o job que gera o arquivo port_fowarding_command
- inserir o hash no final do comando e executar em terminal na máquina local para criar o túnel:
  - `ssh -L localhost:8888:dgx05:11010 ssh.axisapps.io -l 5a2a2781f6d34cbe8e7f651a8b2b7410`
- entrar no jupyter notebook: http://localhost:8888
- Entrar no jupyter principal

Acessar o notebook localmente após a criação do túnel: http://localhost:8888/
Os Labs F-MINST e Climate também foram disponibilizados no colab em: 
https://colab.research.google.com/drive/1iGfkeEbDQKaU7tmDigS_kR2O6P-SmPKQ?usp=sharing

**Lab com o F-MINST**
Disponível no LupyterLab da NVIDIA
Neste Lab foram variados os números de neurônios e camadas. Em seguida, foi usada uma rede convolucional 2d, que melhorou a acurácia de 0.78 para 0.90
Foram armazenadas as alterações em:
https://github.com/deniseiras/EscolaVeraoSantosDumont2023

### Dia  8
**Labs com predição de furacão com CNNs:**
Não foi executado por completo.
Foram armazenadas as alterações em:
https://github.com/deniseiras/EscolaVeraoSantosDumont2023

**Hackaton no JupyterLab da NVIDIA**
O Lab do Hackaton  foi executado no JupyterLab da NVIDIA (Competition.ipynb) Foram armazenadas as alterações em:

https://github.com/deniseiras/EscolaVeraoSantosDumont2023
Também está disponível no https://github.com/openhackathons-org/gpubootcamp/tree/master/hpc_ai/ai_science_cfd

Foram variados parâmetros, onde se encontrou a melhor perda em base de testes ao:
- diminuir o batchsize (4?) para utilizar mais imagens e obter uma melhor conversão
- Habilitar a opção dos gates da RESNET
- Não foi finalizada a última execução (Kernel estava sendo finalizado por algum motivo desconhecido)

> 
> batch_size = 3
> rate = 0.25
> gated = True
> depth = 5
> lr = 0.0001
> 60 Epochs
> 3/3 [==============================] - 1s 7ms/step - loss: 0.7776
> The loss over the test dataset 0.7775589823722839
> 

Email pós evento:

> Dear all,
> 
> Thank you for participating in the LNCC AI for Science Bootcamp! We hope that this event was informative and that you found your time well spent. 
> 
> Here are just a few things to note as we close out the Bootcamp:
> 
> 1. All presentations and recordings can either be found in the [Slack Workspace](https://join.slack.com/t/lnccaiforscie-ry54632/shared_invite/zt-1mpy9h8oh-nwnNHvl63QUGKiZvqiNfHg), or in this shared [Google Drive folder](https://drive.google.com/drive/folders/1yNBIe8Vsrkuj1zu3qikLH40eb8nqzDWK?usp=share_link).
> 2. We encourage you to visit our [Github](https://github.com/openhackathons-org/gpubootcamp) for more open resources.
> 3. Please take a moment to fill out this brief survey. Your feedback will be greatly appreciated as it helps us to improve our future events: https://forms.gle/dtXB5yvPQ2tZRVSn9
> 4. NVIDIA cluster access will be revoked later today. However, two of the labs can always be accessed via [Google Collab](https://colab.research.google.com/drive/1iGfkeEbDQKaU7tmDigS_kR2O6P-SmPKQ?usp=sharing).
> Last, but not least, your Hackathon/Bootcamp experience doesn’t have to end here! You can also apply to attend [another event](https://www.openhackathons.org/s/upcoming-events) or apply to be a mentor. 
> 
> Thank you so much again for your participation and hard work.
> 
> We sincerely hope to see you again!
> 
> Happy programming!
> The Open Hackathons Team
> 






