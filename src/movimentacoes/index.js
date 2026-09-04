const route = require("express").Router();
const conexao = require("../database/config.js")



route.post("/insert",(req,res)=>{
    conexao.query(`INSERT INTO movimentacoes SET ?`,req.body,(error,result)=>{
        if(error){
        return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
    }
    return res.status(201).send({flag:`OK`,payload:result})
    })
});

route.get("/list",(req,res)  =>{
    conexao.query(`SELECT * FROM movimentacoes`,(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_id/:id",(req,res)=>{
    conexao.query(`SELECT * FROM movimentacoes WHERE id=?`,req.params.id,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_tipomov/:tipomov",(req,res)=>{
    conexao.query(`SELECT * FROM movimentacoes WHERE tipo_movimentacao=?`,req.params.tipomov,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})



route.get("/list_responsavel/:responsavel",(req,res)=>{
    const q = `%${req.params.responsavel}%`
    conexao.query(`SELECT * FROM movimentacoes WHERE responsavel_destino LIKE ?`,q,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})


route.get("/list_observacoes/:observacoes",(req,res)=>{
    const q = `%${req.params.observacoes}%`
    conexao.query(`SELECT * FROM movimentacoes WHERE observacoes LIKE ?`,q,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})


route.put("/update/:id",(req,res)=>{
    conexao.query(`UPDATE movimentacoes SET ? WHERE id = ?`,[req.body, req.params.id],(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao tentar atualizar os dados da patrimonio -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,playload:result})
    })
})

module.exports = route;