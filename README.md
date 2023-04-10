# Blockchain Federated Learning (BCFL)

#### Algorithm description

>1. Each client $k\in K$ retrieves the model $\large w_t$ (model weights on round $t$) from blockchain and participates in the learning procedure for the current round $t$
>2. The client $k$ locally takes one step of gradient descent $\large g_k$ on the model $\large w_t$ using his local dataset $D_k$ and uploads the results $\large P_t^k$ (model parameters $\big \langle$ *gradients, weights* $\big \rangle$ of client $k$ on round $t$) to blockchain. If the client is the last one, the smart contract emits the event which informs all (subscribed to event) participants $C \subseteq K$ that $\large P_t^C$ (all client parameters in the round $t$) are uploaded and picks up randomly an aggregator $\alpha \in C$
>3. Subsequently the smart contract emits a second event which includes the address of aggregator for the round $t$
>4. At this point, only the aggregator can retrieve the client parameters $\large P_t^C$
>5. The aggregator runs the aggregation algorithm locally
>6. The aggregator updates the model $\large w_{t+1} \leftarrow w_t$ on blockchain
>7. Finally, the smart contract emits the last event which informs the participants $C$ for the model update and to prepare for the next round $t+1$
