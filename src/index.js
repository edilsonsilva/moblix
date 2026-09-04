const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");
const route_instituicoes = require("./instituicao");
const route_usuarios = require("./usuarios");
const route_turmas = require("./turmas");
const route_locais = require("./locais");
const route_categorias = require("./categorias");
const route_patrimonios = require("./patrimonios");
const route_movimentacoes = require("./movimentacoes");
const route_baixas_patrimoniais = require("./baixas_patrimoniais");




const app = express();
app.use(express.json());
app.use(helmet());
app.use(morgan("combined"));
app.use(cors());

//---------------Instituições -----------------------------------------
app.use("/api/v1/instituicoes",route_instituicoes);


//--------------Usuarios-----------------------------------------------
app.use("/api/v1/usuarios",route_usuarios);


//--------------turmas-----------------------------------------------
app.use("/api/v1/turmas",route_turmas);

//--------------locais-----------------------------------------------
app.use("/api/v1/locais",route_locais);

//--------------categorias-----------------------------------------------
app.use("/api/v1/categorias",route_categorias);

//--------------patrimonio-----------------------------------------------
app.use("/api/v1/patrimonios",route_patrimonios);

//--------------movimentacoes-----------------------------------------------
app.use("/api/v1/movimentacoes",route_movimentacoes);

//--------------baixa_patrimoniais-----------------------------------------------
app.use("/api/v1/baixas_patrimoniais",route_baixas_patrimoniais);


app.listen(5000,()=>console.log(`servindor online`))
